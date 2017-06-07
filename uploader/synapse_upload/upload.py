import os
import sys
import logging
from deriva_io.deriva_upload import DerivaUpload
from deriva_qt.upload_gui.upload_app import DerivaUploadGUI

DESC = "Synapse Data Upload Utility"
INFO = "For more information see: https://github.com/informatics-isi-edu/fishspy/uploader"


class SynapseUpload(DerivaUpload):
    config_dir = "~/.deriva/synapse/synapse-upload"

    def __init__(self, config, credentials):
        DerivaUpload.__init__(self, config, credentials)

    @staticmethod
    def getInstance(config=None, credentials=None):
        return SynapseUpload(config, credentials)

    def getDeployedConfigFilePath(self):
        return os.path.join(os.path.expanduser(
            os.path.normpath(self.config_dir)), DerivaUpload.DefaultConfigFileName)

    def getDeployedTransferStateFilePath(self):
        return os.path.join(os.path.expanduser(
            os.path.normpath(self.config_dir)), DerivaUpload.DefaultTransferStateFileName)

    def getAccessionInfo(self, file_path, asset_mapping, match_groupdict):
        base_name = self.getFileDisplayName(file_path)
        file_type = asset_mapping['synapse_file_type']
        query_url_template = asset_mapping['query_url_template']
        base_record_type = asset_mapping['base_record_type']
        if match_groupdict:
            results = self.catalog.get(query_url_template % match_groupdict).json()
            if results:
                return base_record_type, results[0]
            else:
                raise ValueError('File "%s" does not match an existing %s record in the catalog.'
                                 % (base_name, file_type))
        else:
            raise ValueError('File "%s" does not look like a %s file name.' % (base_name, file_type))

    @staticmethod
    def getUpdateInfo(accession, url, asset_mapping):
        url_column = asset_mapping['url_tracking_column']
        accession_info = accession[1]
        original = {'ID': accession_info['ID']}
        update = original.copy()

        if url_column:
            original[url_column] = accession_info[url_column]
            if accession_info[url_column]:
                if accession_info[url_column] != url:
                    raise ValueError('A different file already exists for accession ID %s.' % accession_info['ID'])
            update[url_column] = url

        return original, update
        
    def uploadFile(self, file_path, asset_mapping, match_groupdict, callback=None):
        """

        :param file_path:
        :param asset_mapping:
        :param match_groupdict:
        :param callback:
        :return:
        """
        base_name = self.getFileDisplayName(file_path)
        logging.info("Processing file: [%s]." % base_name)
        accession_info = self.getAccessionInfo(file_path, asset_mapping, match_groupdict)
        object_name = '/hatrac/Zf/%s/%s' % (accession_info[1]["Subject"], base_name)
        content_type = self.guessContentType(file_path)

        url = self._hatracUpload(
            object_name,
            file_path,
            content_type=content_type,
            chunked=True,
            create_parents=True,
            allow_versioning=False,
            callback=callback)

        original_info, update_info = self.getUpdateInfo(accession_info, url, asset_mapping)
        if original_info != update_info:
            logging.info("Updating catalog for file: [%s]." % base_name)
            self._catalogRecordUpdate(self.getCatalogTable(asset_mapping), original_info, update_info)


def main():
    gui = DerivaUploadGUI(SynapseUpload, DESC, INFO, cookie_persistence=False)
    gui.main()

if __name__ == '__main__':
    sys.exit(main())
