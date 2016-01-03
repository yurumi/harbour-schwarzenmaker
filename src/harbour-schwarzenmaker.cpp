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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QTranslator>
#include <QLocale>
#include <QGuiApplication>
#include <QtGui>
#include <QtQml>
#include <QTimer>
#include <QProcess>
#include <QQuickView>
#include "applibrary.h"
#include "viewhelper.h"
#include "filemodel.h"
#include "avatarimageprovider.h"

int main(int argc, char *argv[])
{
  QScopedPointer<QGuiApplication> application(SailfishApp::application(argc, argv));
  application->setApplicationName("harbour-schwarzenmaker");

  qmlRegisterType<FileModel>("harbour.schwarzenmaker.FileModel", 1, 0, "FileModel");

  appLibrary* applib = new appLibrary();
  QScopedPointer<ViewHelper> helper(new ViewHelper(application.data()));
  AvatarImageProvider* avatarImageProvider = new AvatarImageProvider();

  QScopedPointer<QQuickView> view(SailfishApp::createView());
  QQmlEngine* engine = view->engine();
  engine->addImageProvider(QLatin1String("avatarimage"), avatarImageProvider);
  QObject::connect(engine, SIGNAL(quit()), application.data(), SLOT(quit()));

  view->rootContext()->setContextProperty("appLibrary", applib);
  view->rootContext()->setContextProperty("viewHelper", helper.data());
  view->rootContext()->setContextProperty("avatarImageProvider", avatarImageProvider);

  view->setSource(SailfishApp::pathTo("qml/harbour-schwarzenmaker.qml"));
  view->show();

  return application->exec();
}

