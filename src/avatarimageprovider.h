#ifndef AVATARIMAGEPROVIDER_H
#define AVATARIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QObject>

class AvatarImageProvider : public QObject, public QQuickImageProvider
{
  Q_OBJECT
  
public:
  AvatarImageProvider();

  Q_INVOKABLE void loadImageFile(const QString &filename);
  QPixmap requestPixmap(const QString &id, QSize* size, const QSize &requestedSize);
    
signals:

public slots:
};

#endif // AVATARIMAGEPROVIDER_H
