# -*- mode: python -*-

block_cipher = None


a = Analysis(['uploader\\upload.py'],
             pathex=[''],
             binaries=None,
             datas=[('conf', 'conf')],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)

pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='synapse-uploader',
          debug=False,
          strip=False,
          upx=True,
          console=True )

# for MacOS, if needed
app = BUNDLE(exe,
         name='synapse-uploader.app',
         icon=None,
         bundle_identifier=None,
         info_plist={'NSHighResolutionCapable': 'True'})
