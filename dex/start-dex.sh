#!/bin/sh

echo "\
issuer: http://sigstore-dex:6000\n\
storage:\n\
  type: sqlite3\n\
  config:\n\
    file: /var/dex/dex.db\n\
web:\n\
  http: 0.0.0.0:6000\n\
frontend:\n\
  issuer: sigstore\n\
  theme: light\n\
logger:\n\
  level: \"debug\"\n\
  format: \"json\"\n\
oauth2:\n\
  responseTypes: [ \"code\" ]\n\
  skipApprovalScreen: false\n\
  alwaysShowLoginScreen: true\n\
staticClients:\n\
  - id: sigstore\n\
    public: true\n\
    name: 'sigstore'\n\
connectors:\n\
  - type: github\n\
    id: github-sigstore-test\n\
    name: GitHub\n\
    config:\n\
      clientID: ${GITHUB_CLIENT_ID}\n\
      clientSecret: ${GITHUB_CLIENT_SECRET}\n\
      redirectURI: http://sigstore-dex:6000/callback\n\
" > /etc/dex/dex-config.yaml

# Start the Dex server
exec dex serve /etc/dex/dex-config.yaml
