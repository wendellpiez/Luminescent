# Original borrowed from https://github.com/robrohan/gedit-cfml/blob/master/install.sh

echo "Refreshing LMNL syntax settings in gedit ..."
gtkDir="/usr/share/gtksourceview-3.0"
if [ ! -d $gtkDir ]; then
  gtkDir="/usr/share/gtksourceview-2.0"
fi

sudo cp lmnl.lang         $gtkDir/language-specs/lmnl.lang
sudo cp lmnl-oblivion.xml $gtkDir/styles/lmnl-oblivion.xml

echo "... done."
