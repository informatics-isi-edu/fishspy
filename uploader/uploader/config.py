DEFAULT_CONFIG = {
  "server": {
    "protocol": "https",
    "host": "synapse-dev.isrd.isi.edu",
    "catalog_id": 1
  },
  "asset_mappings": [
    {
      "file_pattern": "^(.*[/\\\\])?(?P<ID>Bhv[^.]+)[.]m4v$",
      "ext_pattern": ".*[.](?P<ext>m4v)$",
      "checksum_types": [
        "md5"
      ],
      "synapse_file_type": "behavior movie",
      "query_url_template": "/entity/Zebrafish:Behavior/ID=%(ID)s",
      "base_record_type": [
        "Zebrafish",
        "Behavior"
      ],
      "url_tracking_column": "Raw URL"
    },
    {
      "file_pattern": "^(.*[/\\\\])?(?P<ID>Img[^.]+)[.]ome[.]tiff?$",
      "ext_pattern": ".*[.](?P<ext>ome[.]tiff?)$",
      "checksum_types": [
        "md5"
      ],
      "synapse_file_type": "spim image",
      "query_url_template": "/entity/Zebrafish:Image/ID=%(ID)s",
      "base_record_type": [
        "Zebrafish",
        "Image"
      ],
      "url_tracking_column": "URL"
    },
    {
      "file_pattern": "^(.*[/\\\\])?(?P<ID>CropImg[^.]+)[.]ome[.]tiff?$",
      "ext_pattern": ".*[.](?P<ext>ome[.]tiff?)$",
      "checksum_types": [
        "md5"
      ],
      "synapse_file_type": "cropped image",
      "query_url_template": "/attribute/I:=Zebrafish:Image/Zebrafish:Image%%20Region/ID=%(ID)s/*,Subject:=I:Subject",
      "base_record_type": [
        "Zebrafish",
        "Image Region"
      ],
      "url_tracking_column": None
    },
    {
      "file_pattern": "^(.*[/\\\\])?(?P<ID>(Roi|Crop|Syn)[^-._]+)[-._](segments|synapses)[.]csv$",
      "ext_pattern": ".*[.](?P<ext>csv)$",
      "checksum_types": [
        "md5"
      ],
      "synapse_file_type": "synapse list",
      "query_url_template": "/attribute/I:=Zebrafish:Image/Zebrafish:Image%%20Region/ID=%(ID)s/*,Subject:=I:Subject",
      "base_record_type": [
        "Zebrafish",
        "Image Region"
      ],
      "url_tracking_column": "Segments URL"
    },
    {
      "file_pattern": "^(.*[/\\\\])?(?P<ID>(Roi|Crop|Nuc)[^-._]+)[-._]nuclei[.]csv$",
      "ext_pattern": ".*[.](?P<ext>csv)$",
      "checksum_types": [
        "md5"
      ],
      "synapse_file_type": "nucleus list",
      "query_url_template": "/attribute/I:=Zebrafish:Image/Zebrafish:Image%%20Region/ID=%(ID)s/*,Subject:=I:Subject",
      "base_record_type": [
        "Zebrafish",
        "Image Region"
      ],
      "url_tracking_column": "Segments URL"
    }
  ]
}
