import os
import sys
import logging
from deriva_common import read_config, read_credentials, resource_path, init_logging, format_exception, urlquote
from deriva_io.deriva_upload import DerivaUpload


class FishspyUpload(DerivaUpload):

    behavior_map = dict()
    invalid_accessions = list()

    def __init__(self, config, credentials):
        DerivaUpload.__init__(self, config, credentials)

    def cleanup(self):
        self.behavior_map.clear()
        self.invalid_accessions = []

    def _getSubjectID(self, accession):
        """
        Helper function that queries the catalog to get a subject id for a given accession.
        :param accession:
        :return: the subject_id, or None
        """
        subject_id = self.behavior_map.get(accession)
        if not subject_id and accession not in self.invalid_accessions:
            try:
                logging.debug("Validating accession: %s" % accession)
                path = '/attribute/A:=Zebrafish:Behavior/ID=%s/$A/Subject@sort(Subject)?limit=1' % \
                       urlquote(accession, '')
                r = self.catalog.get(path)
                resp = r.json()
                if len(resp) > 0:
                    subject_id = resp[0]['Subject']
                    self.behavior_map[accession] = subject_id
            except:
                (etype, value, traceback) = sys.exc_info()
                logging.error(format_exception(value))

        return subject_id

    def uploadFile(self, file_path, asset_mapping, callback=None):
        """

        :param file_path:
        :param asset_mapping:
        :param callback:
        :return:
        """
        logging.info("Uploading file: [%s]" % file_path)

        # 1. Retrieve the subject id for the matched accession from the catalog
        accession = os.path.splitext(os.path.basename(file_path))[0]
        subject_id = self._getSubjectID(accession)
        if not subject_id:
            self.invalid_accessions.append(accession)
            logging.warn("Ignoring file [%s] due to invalid target accession: %s" % (file_path, accession))
            return False

        # 2. Assemble the attributes used for the upload
        file_name = self.getFileDisplayName(file_path, asset_mapping)
        content_type = self.guessContentType(file_path)
        hashes = self.getFileHashes(file_path, asset_mapping.get('checksum_types', ['md5']))
        hash_type = list(hashes.keys())[0]
        hash_base64 = hashes[hash_type][1]

        # 3. Perform the hatrac upload -- duplicates (based on object name and md5 hash) will not be uploaded
        url = None
        try:
            path = "/".join([asset_mapping['hatrac_namespace'], subject_id, file_name])
            url = self.store.put_loc(path,
                                     file_path,
                                     {"Content-Type": content_type},
                                     hash_base64,
                                     chunked=True,
                                     create_parents=True,
                                     allow_versioning=False,
                                     callback=callback)
        except:
            (etype, value, traceback) = sys.exc_info()
            logging.error("Unable to upload file: [%s] - %s" % (file_path, format_exception(value)))

        if not url:
            return False

        # 4. update the record in the catalog -- fail if there is already an existing entry for this file
        catalog_table = asset_mapping['catalog_table']
        return self._catalogRecordUpdate(catalog_table,
                                         {"ID": accession, "Raw URL": None},
                                         {"ID": accession, "Raw URL": url})


def upload(path):
    init_logging(level=logging.INFO)
    config = read_config(resource_path(os.path.join('conf', 'config.json')))
    credentials = read_credentials(resource_path(os.path.join('conf', 'credentials.json')))
    fs_upload = FishspyUpload(config, credentials)
    if fs_upload.scanDirectory(path, False):
        fs_upload.uploadFiles()
    if fs_upload.failed_uploads:
        logging.warning("The following file(s) failed to upload due to errors:\n\n%s\n" %
                        '\n'.join(sorted(fs_upload.failed_uploads)))
    if fs_upload.skipped_uploads:
        logging.warning("The following file(s) were skipped because they did not satisfy the matching criteria "
                        "of the configuration:\n\n%s" % '\n'.join(sorted(fs_upload.skipped_uploads)))
    fs_upload.cleanup()

if __name__ == '__main__':
    sys.exit(upload(sys.argv[1]))
