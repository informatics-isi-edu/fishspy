import os
import re
import sys
from deriva_common import urlquote
from deriva_io.deriva_upload import DerivaUpload
from deriva_qt.upload_gui.upload_app import DerivaUploadGUI
from synapse_upload.config import DEFAULT_CONFIG

DESC = "Synapse Data Upload Utility"
INFO = "For more information see: https://github.com/informatics-isi-edu/fishspy/uploader"


class SynapseUpload(DerivaUpload):
    def __init__(self, config, credentials):
        DerivaUpload.__init__(self, config, credentials)

    @staticmethod
    def getInstance(config=None, credentials=None):
        return SynapseUpload(config, credentials)

    @staticmethod
    def getDefaultConfig():
        return DEFAULT_CONFIG

    @staticmethod
    def getDefaultConfigFilePath():
        return os.path.join(os.path.expanduser(os.path.normpath("~/.deriva/synapse/synapse-upload")), 'config.json')

    def getAccessionInfo(self, file_path, asset_mapping):
        base_name = os.path.basename(file_path)
        pattern = asset_mapping['file_pattern']
        file_type = asset_mapping['synapse_file_type']
        query_url_template = asset_mapping['query_url_template']
        base_record_type = asset_mapping['base_record_type']
        m = re.match(pattern, base_name)
        if m:
            results = self.catalog.get(query_url_template % m.groupdict()).json()
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
        
    def uploadFile(self, file_path, asset_mapping, callback=None):
        """

        :param file_path:
        :param asset_mapping:
        :param callback:
        :return:
        """
        schema_name, table_name = asset_mapping['base_record_type']
        base_name = os.path.basename(file_path)
        accession_info = self.getAccessionInfo(file_path, asset_mapping)
        object_name = '/hatrac/Zf/%s/%s' % (accession_info[1]["Subject"], base_name)
        content_type = self.guessContentType(file_path)

        url = self.store.put_loc(
            object_name,
            file_path,
            {"Content-Type": content_type},
            chunked=True,
            create_parents=True,
            allow_versioning=False,
            callback=callback
        )

        original_info, update_info = self.getUpdateInfo(accession_info, url, asset_mapping)
        if original_info != update_info:
            return self._catalogRecordUpdate(
                '%s:%s' % (urlquote(schema_name), urlquote(table_name)),
                original_info,
                update_info
            )


def main():
    gui = DerivaUploadGUI(SynapseUpload, DESC, INFO)
    gui.main()

if __name__ == '__main__':
    sys.exit(main())
