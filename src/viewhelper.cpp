/*
  Schwarzenmaker.
  Copyright (C) 2015 Thomas Eigel
  Contact: Thomas Eigel <yurumi@gmx.de>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "viewhelper.h"

#include <qpa/qplatformnativeinterface.h>
#include <QDesktopServices>
#include <QTimer>
#include <QDebug>

ViewHelper::ViewHelper(QObject *parent) :
  QObject(parent),
  m_overlayView(NULL)
{
}

void ViewHelper::createOverlay()
{
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

  m_overlayView->rootContext()->setContextProperty("msg", &m_msg);
  m_overlayView->setSource(SailfishApp::pathTo("qml/components/overlay.qml"));
  m_overlayView->create();
  QPlatformNativeInterface *native = QGuiApplication::platformNativeInterface();
  native->setWindowProperty(m_overlayView->handle(), QLatin1String("CATEGORY"), "notification");
  native->setWindowProperty(m_overlayView->handle(), QLatin1String("MOUSE_REGION"), QRegion(0, 0, 0, 0));

  // m_overlayView->showNormal();
  hideOverlay();
}

void ViewHelper::hideOverlay()
{
  m_overlayView->hide();
}

void ViewHelper::unhideOverlay()
{
  m_overlayView->showNormal();
}
