# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-schwarzenmaker

CONFIG += sailfishapp c++11
QT += dbus gui-private sql

SOURCES += src/harbour-schwarzenmaker.cpp \
    src/applibrary.cpp \
    src/viewhelper.cpp \
    src/avatarimageprovider.cpp \
    src/filemodel.cpp \
    src/statfileinfo.cpp

OTHER_FILES += qml/harbour-schwarzenmaker.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-schwarzenmaker.changes.in \
    rpm/harbour-schwarzenmaker.spec \
    rpm/harbour-schwarzenmaker.yaml \
    translations/*.ts \
    harbour-schwarzenmaker.desktop \
    qml/pages/EditWorkoutSettings.qml \
    qml/pages/EntryEditPage.qml \
    qml/pages/InitPage.qml \
    qml/pages/WorkoutEditPage.qml \
    qml/pages/WorkoutItemDelegate.qml \
    qml/pages/WorkoutPerformancePage.qml \
    qml/pages/WorkoutPage.qml \
    qml/components/IconContextMenu.qml \
    qml/components/IconMenuItem.qml \
    qml/js/storage.js

include(third_party/notifications.pri)

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-schwarzenmaker-de.ts

RESOURCES += \
    res.qrc

HEADERS += \
    src/applibrary.h \
    src/viewhelper.h \
    src/avatarimageprovider.h \
    src/filemodel.h \
    src/statfileinfo.h

DISTFILES += \
    qml/pages/DirectoryPage.qml

