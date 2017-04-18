import os
import re
import sys
from deriva_common import read_config, read_credential, resource_path, init_logging, format_exception, urlquote
from deriva_common.base_cli import BaseCLI
from deriva_io.deriva_upload import DerivaUpload
from deriva_qt.upload_gui import upload_app
from uploader.config import DEFAULT_CONFIG


class SynapseUpload(DerivaUpload):
    def __init__(self, config, credentials):
        DerivaUpload.__init__(self, config, credentials)

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
        file_type = asset_mapping['synapse_file_type']
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

    @staticmethod
    def upload(data_path, config_file=None, credential_file=None):
        if not (config_file and os.path.isfile(config_file)):
            config_file = os.path.join(os.path.expanduser(
                os.path.normpath("~/.deriva/synapse/synapse-upload")), 'config.json')
        config = read_config(config_file, create_default=True, default=DEFAULT_CONFIG)
        credential = read_credential(credential_file, create_default=True)

        synapse_upload = SynapseUpload(config, credential)
        synapse_upload.scanDirectory(data_path, False)
        synapse_upload.uploadFiles()
        synapse_upload.cleanup()

    @staticmethod
    def upload_gui(config_file=None, credential_file=None):
        if not (config_file and os.path.isfile(config_file)):
            config_file = os.path.join(os.path.expanduser(
                os.path.normpath("~/.deriva/synapse/synapse-upload")), 'config.json')
        config = read_config(config_file, create_default=True, default=DEFAULT_CONFIG)
        credential = read_credential(credential_file, create_default=False) if credential_file else None

        synapse_upload = SynapseUpload(config, credential)
        upload_app.launch(
            synapse_upload, config_file, credential_file=credential_file, window_title="Synapse Data Upload Utility")


def main():
    cli = BaseCLI("Synapse data upload utility",
                  "For more information see: https://github.com/informatics-isi-edu/fishspy/uploader")
    cli.parser.add_argument('data_path', nargs="?", metavar="<dir>", help="Path to the input directory")
    args = cli.parse_cli()
    if args.data_path is None:
        print("\nError: Input directory not specified.\n")
        cli.parser.print_usage()
        return 1

    try:
        SynapseUpload.upload(os.path.abspath(args.data_path), args.config_file, args.credential_file)
    except Exception as e:
        sys.stderr.write(format_exception(e))
        return 1
    finally:
        sys.stderr.write('\n\n')
    return 0

if __name__ == '__main__':
    sys.exit(main())
