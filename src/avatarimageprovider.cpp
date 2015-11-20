#include "avatarimageprovider.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDebug>

AvatarImageProvider::AvatarImageProvider()
  : QObject(0),
    QQuickImageProvider(QQuickImageProvider::Pixmap)
{
  // QFile file("/home/thomske/03_Projekte/Tests/QmlImageProvider/img/image.png");
  // if (!file.open(QIODevice::ReadOnly)) return;
  // QByteArray byteArray = file.readAll();

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
