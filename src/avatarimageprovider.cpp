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

#include "avatarimageprovider.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDebug>

AvatarImageProvider::AvatarImageProvider()
  : QObject(0),
    QQuickImageProvider(QQuickImageProvider::Pixmap)
{
  QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
  // db.setHostName("localhost");
  db.setDatabaseName("avatardb");
  // db.setUserName("user");
  // db.setPassword("0000");
  if (!db.open()){
    qDebug() << "Database Error" << db.lastError().text();
  }
   
  // QSqlQuery query(db);
  // query.exec("DROP IF EXISTS imgtable;");
  // query.exec("CREATE TABLE IF NOT EXISTS imgtable (imgdata BLOB)");
  // query.prepare("INSERT INTO imgtable (imgdata) VALUES (?)");
  // query.addBindValue(byteArray);
  // query.exec();
  // db.commit();
}

void AvatarImageProvider::loadImageFile(const QString &filename)
{
  qDebug() << "AvatarImageProvider::loadImageFile --> " << filename;
}

QPixmap AvatarImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
  QSqlQuery query("SELECT imgdata FROM imgtable");
  query.next();
  QByteArray array = query.value(0).toByteArray();

  // QPixmap pixmap = QPixmap();
  // pixmap.loadFromData(array);

  // int width = 100;
  // int height = 50;

  QPixmap pixmap(":/img/avatar_default.png");
  
  if (size){
    // *size = QSize(width, height);
    *size = pixmap.size();
  }
  // QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
  // 		 requestedSize.height() > 0 ? requestedSize.height() : height);
  // pixmap.fill(QColor(id).rgba());

  return pixmap;
}
