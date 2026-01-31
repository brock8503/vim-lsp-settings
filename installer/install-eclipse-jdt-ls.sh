#!/bin/sh

set -e

curl -o jdt-language-server-latest.tar.gz 'https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz'
curl -o lombok.jar 'https://projectlombok.org/downloads/lombok.jar'
tar xvf jdt-language-server-latest.tar.gz
rm jdt-language-server-latest.tar.gz

osType="$(uname -s)"
echo "$osType"
case "$osType" in
Darwin*) configDir=config_mac ;;
Linux*) configDir=config_linux ;;
*) configDir=config_linux ;;
esac

cat <<EOF >eclipse-jdt-ls
#!/bin/sh
DIR=\$(cd \$(dirname \$0); pwd)
LAUNCHER=\$(ls \$DIR/plugins/org.eclipse.equinox.launcher_*.jar)
java -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
  -Dosgi.bundles.defaultStartLevel=4 \\
  -Declipse.product=org.eclipse.jdt.ls.core.product \\
  -Dlog.protocol=true \\
  -Dlog.level=ALL \\
  -Dfile.encoding=UTF-8 \\
  -Xmx1G -XX:+UseG1GC -XX:+UseStringDeduplication \\
  --add-modules=ALL-SYSTEM \\
  --add-opens java.base/java.util=ALL-UNNAMED \\
  --add-opens java.base/java.lang=ALL-UNNAMED \\
  -javaagent:\$DIR/lombok.jar \\
  -jar \$LAUNCHER \\
  -configuration \$DIR/config_mac \\
  -data \$DIR/data
EOF

chmod +x eclipse-jdt-ls
