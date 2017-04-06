import os
import sys
import logging
from deriva_common import read_config, read_credentials, resource_path, init_logging, format_exception, urlquote
from deriva_io.deriva_upload import DerivaUpload

class SynapseUpload (DerivaUpload):

    def __init__(self, config, credentials):
        DerivaUpload.__init__(self, config, credentials)

    def getAccessionInfo(file_path, asset_mapping):
        base_name = os.path.basename(file_path)
        file_type = asset_mapping['synapse_file_type']

        _region_url_templ = '/attribute/I:=Zebrafish:Image/Zebrafish:Image%20Region/ID=%(ID)s/*,Subject:=I:Subject'

        pattern, query_url_template, base_record_type = {
            'behavior movie': (
                '(?P<ID>[^.]+)[.]m4v$',
                '/entity/Zebrafish:Behavior/ID=%(ID)s',
                'Behavior'
            ),
            'spim image': (
                '(?P<ID>[^.]+)[.]ome[.]tiff?$',
                '/entity/Zebrafish:Image/ID=%(ID)s',
                'Image',
            ),
            'cropped image': (
                '(?P<ID>[^.]+)[.]ome[.]tiff?$',
                _region_url_templ,
                'Image%20Region'
            ),
            'synapse list': (
                '(?P<ID>[^-._]+)[-._](segments|synapses)[.]csv$',
                _region_url_templ,
                'Image%20Region'
            ),
            'nucleus list': (
                '(?P<ID>[^-._]+)[-._]nuclei[.]csv$',
                _region_url_templ,
                'Image%20Region'
            ),
        }[file_type]
        
        m = re.match(pattern, base_name)
        if m:
            results = self.catalog.get(query_url_template % m.groupdict()).json()
            if results:
                return (base_record_type, row[0])
            else:
                raise ValueError('File "%s" does not match an existing %s record in the catalog.' % (base_name, file_type))
        else:
            raise ValueError('File "%s" does not look like a %s file name.' % (base_name, file_type))

    def getUpdateInfo(accession_info, url, asset_mapping):
        file_type = asset_mapping['synapse_file_type']
        url_column = {
            'behavior movie': 'Raw URL',
            'spim image': 'URL',
            'cropped image': None,
            'synapse list': 'Segments URL',
            'nucleus list': 'Segments URL',
        }[file_type]

        original = {'ID': accession_info['ID']}
        update = {}

        if url_column:
            if accession_info[url_column]:
                if accession_info[url_column] == url:
                    pass
                else:
                    raise ValueError('A different file already exists for accession ID %s.' % accession_info['ID'])
            else:
                update[url_column] = url

        return original, update
        
    def uploadFile(self, file_path, asset_mapping, callback=None):
        """

        :param file_path:
        :param asset_mapping:
        :param callback:
        :return:
        """
        base_name = os.path.basename(file_path)
        base_record_type, accession_info = self.getAccessionInfo(file_path, asset_mapping)
        object_name = '/hatrac/Zf/%s/%s' % (accession_info['Subject'], base_name])
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
        
        return self._catalogRecordUpdate(
            'Zebrafish:%s' % base_record_type,
            original_info,
            update_info
        )

def upload(path):
    init_logging(level=logging.INFO)
    config = read_config(resource_path(os.path.join('conf', 'config.json')))
    credentials = read_credentials(resource_path(os.path.join('conf', 'credentials.json')))
    fs_upload = FishspyUpload(config, credentials)
    if fs_upload.scanDirectory(path, False):
        fs_upload.uploadFiles()
    fs_upload.cleanup()

if __name__ == '__main__':
    sys.exit(upload(sys.argv[1]))
