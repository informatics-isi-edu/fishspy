import logging
import sys

from deriva.transfer import DerivaUpload
from deriva.qt import DerivaUploadGUI

DESC = "Synapse Data Upload Utility"
INFO = "For more information see: https://github.com/informatics-isi-edu/fishspy/uploader"


class SynapseUpload(DerivaUpload):

    def __init__(self, config_file=None, credential_file=None, server=None):
        DerivaUpload.__init__(self, config_file, credential_file, server)

    @classmethod
    def getVersion(cls):
        return "synapse-20170830"

    @classmethod
    def getServers(cls):
        return [
            {
                "host": "synapse.isrd.isi.edu",
                "desc": "Synapse Production",
                "catalog_id": 1,
                "default": True
            },
            {
                "host": "synapse-staging.isrd.isi.edu",
                "desc": "Synapse Staging",
                "catalog_id": 1
            },
            {
                "host": "synapse-dev.isrd.isi.edu",
                "desc": "Synapse Development",
                "catalog_id": 1
            }
          ]

    @classmethod
    def getConfigPath(cls):
        return "~/.deriva/synapse/synapse-upload"

    def getAccessionInfo(self, file_path, asset_mapping, match_groupdict):
        base_name = self.getFileDisplayName(file_path)
        file_type = asset_mapping['synapse_file_type']
        query_url_template = asset_mapping['query_url_template']
        if match_groupdict:
            results = self.catalog.get(query_url_template % match_groupdict).json()
            if results:
                return results[0]
            else:
                raise ValueError('File "%s" does not match an existing %s record in the catalog.'
                                 % (base_name, file_type))
        else:
            raise ValueError('File "%s" does not look like a %s file name.' % (base_name, file_type))

    @staticmethod
    def getUpdateInfo(accession, url, asset_mapping):
        url_column = asset_mapping['url_tracking_column']
        original = {'ID': accession['ID']}
        update = original.copy()

        if url_column:
            original[url_column] = accession[url_column]
            if accession[url_column]:
                if accession[url_column] != url:
                    raise ValueError('A different file already exists for accession ID %s.' % accession['ID'])
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
        object_name = '/hatrac/Zf/%s/%s' % (accession_info["Subject"], base_name)
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
