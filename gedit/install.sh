# Original borrowed from https://github.com/robrohan/gedit-cfml/blob/master/install.sh

# Install the LMNL mime type into the system.
# To be used by gedit to bind file type.

echo "Updating MIME database ..."
sudo cp lmnl-mime.xml /usr/share/mime/packages/lmnl-mime.xml
sudo update-mime-database /usr/share/mime

echo "Okay, now writing into gedit installation ..."
gtkDir="/usr/share/gtksourceview-3.0"
if [ ! -d $gtkDir ]; then
  gtkDir="/usr/share/gtksourceview-2.0"
fi

sudo cp lmnl.lang $gtkDir/language-specs/lmnl.lang

echo "Installed!"
