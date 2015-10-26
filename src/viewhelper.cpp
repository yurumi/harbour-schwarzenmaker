#include "viewhelper.h"

#include <qpa/qplatformnativeinterface.h>
#include <QDesktopServices>
#include <QTimer>
#include <QDebug>

ViewHelper::ViewHelper(QObject *parent) :
    QObject(parent),
    view(NULL),
    m_isOverlay(false)
{
}

void ViewHelper::closeOverlay()
{
    QDBusInterface iface("harbour.batteryoverlay.overlay", "/harbour/batteryoverlay/overlay", "harbour.batteryoverlay");
    iface.call(QDBus::NoBlock, "exit");
}

void ViewHelper::checkOverlay()
{
    if (m_isOverlay) {
        Q_EMIT overlayRunning();
    }
    else {
        QDBusInterface iface("harbour.batteryoverlay.overlay", "/harbour/batteryoverlay/overlay", "harbour.batteryoverlay");
        iface.call(QDBus::NoBlock, "checkOverlay");
    }
}

void ViewHelper::startOverlay()
{
    QDesktopServices::openUrl(QUrl::fromLocalFile("/usr/share/applications/harbour-batteryoverlay.desktop"));
}

void ViewHelper::checkActive()
{
    bool inactive = QDBusConnection::sessionBus().registerService("harbour.batteryoverlay.overlay");
    if (inactive) {
        showOverlay();
    }
    // else {
    //     bool newSettings = QDBusConnection::sessionBus().registerService("harbour.batteryoverlay.settings");
    //     if (newSettings) {
    //         showSettings();
    //     }
    //     else {
    //         QDBusInterface iface("harbour.batteryoverlay.settings", "/harbour/batteryoverlay/settings", "harbour.batteryoverlay");
    //         iface.call(QDBus::NoBlock, "show");
    //         qGuiApp->exit(0);
    //         return;
    //     }
    // }
    QDBusConnection::sessionBus().connect("", "", "com.jolla.jollastore", "packageStatusChanged", this, SLOT(onPackageStatusChanged(QString, int)));
}

void ViewHelper::show()
{
    if (view) {
        view->raise();
    }
}

void ViewHelper::exit()
{
    QTimer::singleShot(100, qGuiApp, SLOT(quit()));
}

void ViewHelper::showOverlay()
{
    QDBusConnection::sessionBus().registerObject("/harbour/batteryoverlay/overlay", this, QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportAllSignals);

    m_isOverlay = true;

    qGuiApp->setApplicationName("Battery Overlay");
    qGuiApp->setApplicationDisplayName("Battery Overlay");

    view = SailfishApp::createView();
    view->setTitle("BatteryOverlay");

    QColor color;
    color.setRedF(0.0);
    color.setGreenF(0.0);
    color.setBlueF(0.0);
    color.setAlphaF(0.0);
    view->setColor(color);
    view->setClearBeforeRendering(true);

    view->setSource(SailfishApp::pathTo("qml/components/overlay.qml"));
    view->create();
    QPlatformNativeInterface *native = QGuiApplication::platformNativeInterface();
    native->setWindowProperty(view->handle(), QLatin1String("CATEGORY"), "notification");
    native->setWindowProperty(view->handle(), QLatin1String("MOUSE_REGION"), QRegion(0, 0, 0, 0));

    view->rootContext()->setContextProperty("msg", &m_msg);
    
    // view->showNormal();
    view->hide();
    
    Q_EMIT overlayRunning();
}

void ViewHelper::hideOverlay()
{
  view->hide();
}

void ViewHelper::unhideOverlay()
{
  view->showNormal();
}

void ViewHelper::onPackageStatusChanged(const QString &package, int status)
{
    if (package == "harbour-batteryoverlay" && status != 1) {
        exit();
    }
}

