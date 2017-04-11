import os
import sys
from upload import SynapseUpload
from deriva_common import format_exception
from deriva_common.base_cli import BaseCLI


def main():
    cli = BaseCLI("Synapse data upload utility",
                  "For more information see: https://github.com/informatics-isi-edu/fishspy/uploader")
    cli.parser.add_argument(
        "--data-path", metavar="<path>", required=True, help="Path to data directory")
    args = cli.parse_cli()

    try:
        SynapseUpload.upload(os.path.abspath(args.data_path), args.config_file, args.credential_file)
    except Exception as e:
        sys.stderr.write(format_exception(e))
        return 1
    return 0

if __name__ == '__main__':
    sys.exit(main())
