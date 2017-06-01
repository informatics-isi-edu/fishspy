# -*- mode: python -*-

block_cipher = None

from os import environ as env

a = Analysis(['synapse_upload/upload.py'],
             pathex=[''],
             binaries=None,
             datas=[('conf/config.json', 'conf')],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          exclude_binaries=True,
          name='Facebase Upload',
          strip=False,
          upx=False,
          debug=env.get("DEBUG", False),
          console=env.get("DEBUG", False))

coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=False,
               name='Synapse Upload')

app = BUNDLE(coll,
         name='Synapse Upload.app',
         bundle_identifier='org.qt-project.Qt.QtWebEngineCore',
         info_plist={
            'CFBundleDisplayName': 'Synapse File Upload Utility',
            'CFBundleShortVersionString':'0.1.0',
            'NSPrincipalClass':'NSApplication',
            'NSHighResolutionCapable': 'True'
         })