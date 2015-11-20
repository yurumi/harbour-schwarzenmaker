#include "viewhelper.h"

#include <qpa/qplatformnativeinterface.h>
#include <QDesktopServices>
#include <QTimer>
#include <QDebug>

ViewHelper::ViewHelper(QObject *parent) :
  QObject(parent),
  m_overlayView(NULL),
  m_overlayActive(false)
{
}

// void ViewHelper::closeOverlay()
// {
//   QDBusInterface iface("harbour.schwarzenmaker.overlay", "/harbour/schwarzenmaker/overlay", "harbour.schwarzenmaker");
//   iface.call(QDBus::NoBlock, "exit");
// }

void ViewHelper::checkOverlay()
{
  // qDebug() << "checkOverlay()";
  // if (m_overlayActive) {
  //   qDebug() << "  overlayRunning";
  //   Q_EMIT overlayRunning();
  // }
  // else {
  //   qDebug() << "  overlay NOT Running";
  //   QDBusInterface iface("harbour.schwarzenmaker.overlay", "/harbour/schwarzenmaker/overlay", "harbour.schwarzenmaker");
  //   iface.call(QDBus::NoBlock, "checkOverlay");
  // }
}

// void ViewHelper::startOverlay()
// {
//     QDesktopServices::openUrl(QUrl::fromLocalFile("/usr/share/applications/harbour-batteryoverlay.desktop"));
// }

void ViewHelper::checkActive()
{
  // qDebug() << "checkActive()";
  // bool inactive = QDBusConnection::sessionBus().registerService("harbour.schwarzenmaker.overlay");
  // if(inactive){
    // qDebug() << "  inactive";
    showOverlay();
  // }
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
  // QDBusConnection::sessionBus().connect("", "", "com.jolla.jollastore", "packageStatusChanged", this, SLOT(onPackageStatusChanged(QString, int)));
}

// void ViewHelper::show()
// {
//   if (m_overlayView) {
//     m_overlayView->raise();
//   }
// }

// void ViewHelper::exit()
// {
//   QTimer::singleShot(100, qGuiApp, SLOT(quit()));
// }

void ViewHelper::showOverlay()
{
  qDebug() << "showOverlay()";
  // QDBusConnection::sessionBus().registerObject("/harbour/schwarzenmaker/overlay", this, QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportAllSignals);

  m_overlayActive = true;

  qGuiApp->setApplicationName("Schwarzenmaker Overlay");
  qGuiApp->setApplicationDisplayName("Schwarzenmaker Overlay");

  m_overlayView = SailfishApp::createView();
  m_overlayView->setTitle("SchwarzenmakerOverlay");

  QColor color;
  color.setRedF(0.0);
  color.setGreenF(0.0);
  color.setBlueF(0.0);
  color.setAlphaF(0.0);
  m_overlayView->setColor(color);
  m_overlayView->setClearBeforeRendering(true);

  m_overlayView->setSource(SailfishApp::pathTo("qml/components/overlay.qml"));
  m_overlayView->create();
  QPlatformNativeInterface *native = QGuiApplication::platformNativeInterface();
  native->setWindowProperty(m_overlayView->handle(), QLatin1String("CATEGORY"), "notification");
  native->setWindowProperty(m_overlayView->handle(), QLatin1String("MOUSE_REGION"), QRegion(0, 0, 0, 0));

  m_overlayView->rootContext()->setContextProperty("msg", &m_msg);
    
  // m_overlayView->showNormal();
  hideOverlay();
    
  // Q_EMIT overlayRunning();
}

void ViewHelper::hideOverlay()
{
  m_overlayView->hide();
}

void ViewHelper::unhideOverlay()
{
  m_overlayView->showNormal();
}

// void ViewHelper::onPackageStatusChanged(const QString &package, int status)
// {
//   qDebug() << "onPackageStatusChanged: " << package <<  ", " << status;
//   if (package == "harbour-schwarzenmaker" && status != 1) {
//     exit();
//   }
// }

