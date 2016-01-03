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

#ifndef VIEWHELPER_H
#define VIEWHELPER_H

#include <QObject>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include "sailfishapp.h"
// #include <mlite5/MGConfItem>
#include <QDBusInterface>
#include <QDBusConnection>

class Message : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString currentExerciseTitle READ currentExerciseTitle WRITE setCurrentExerciseTitle NOTIFY currentExerciseTitleChanged)
  Q_PROPERTY(QString currentExerciseDescription READ currentExerciseDescription WRITE setCurrentExerciseDescription NOTIFY currentExerciseDescriptionChanged)
  Q_PROPERTY(QString nextExercise READ nextExercise WRITE setNextExercise NOTIFY nextExerciseChanged)
  Q_PROPERTY(QString nextExerciseDescription READ nextExerciseDescription WRITE setNextExerciseDescription NOTIFY nextExerciseDescriptionChanged)
  Q_PROPERTY(int exerciseDuration READ exerciseDuration WRITE setExerciseDuration NOTIFY exerciseDurationChanged)
  Q_PROPERTY(int remainingExerciseTime READ remainingExerciseTime WRITE setRemainingExerciseTime NOTIFY remainingExerciseTimeChanged)
  
public:
  void setCurrentExerciseTitle(QString title) {
    m_currentExerciseTitle = title;
    emit currentExerciseTitleChanged();
  }

  QString currentExerciseTitle() const {
    return m_currentExerciseTitle;
  }

  void setCurrentExerciseDescription(QString description) {
    m_currentExerciseDescription = description;
    emit currentExerciseDescriptionChanged();
  }

  QString currentExerciseDescription() const {
    return m_currentExerciseDescription;
  }

  void setNextExercise(const QString &a) {
    m_nextExercise = a;
    emit nextExerciseChanged();
  }

  QString nextExercise() const {
    return m_nextExercise;
  }

  void setNextExerciseDescription(QString description) {
    m_nextExerciseDescription = description;
    emit nextExerciseDescriptionChanged();
  }

  QString nextExerciseDescription() const {
    return m_nextExerciseDescription;
  }

  void setRemainingExerciseTime(const int &i) {
    m_remainingExerciseTime = i;
    emit remainingExerciseTimeChanged();
  }

  int remainingExerciseTime() const {
    return m_remainingExerciseTime;
  }

  void setExerciseDuration(const int &i) {
    m_exerciseDuration = i;
    emit exerciseDurationChanged();
  }

  int exerciseDuration() const {
    return m_exerciseDuration;
  }

signals:
  void currentExerciseTitleChanged();
  void currentExerciseDescriptionChanged();
  void nextExerciseChanged();
  void nextExerciseDescriptionChanged();
  void remainingExerciseTimeChanged();
  void exerciseDurationChanged();
  
private:
  QString m_currentExerciseTitle;
  QString m_currentExerciseDescription;
  QString m_nextExercise;
  QString m_nextExerciseDescription;
  int m_exerciseDuration;
  int m_remainingExerciseTime;
};

class ViewHelper : public QObject
{
  Q_OBJECT
  Q_CLASSINFO("D-Bus Interface", "harbour.schwarzenmaker") // necessary?

  public:
  explicit ViewHelper(QObject *parent = 0);

  // Q_INVOKABLE void closeOverlay();
  // Q_INVOKABLE void startOverlay();

  Q_INVOKABLE void setCurrentExerciseTitle(QString title){m_msg.setCurrentExerciseTitle(title);}
  Q_INVOKABLE void setCurrentExerciseDescription(QString description){m_msg.setCurrentExerciseDescription(description);}
  Q_INVOKABLE void setNextExercise(QString nextExercise){m_msg.setNextExercise(nextExercise);}
  Q_INVOKABLE void setNextExerciseDescription(QString description){m_msg.setNextExerciseDescription(description);}
  Q_INVOKABLE void setRemainingExerciseTime(int i){m_msg.setRemainingExerciseTime(i);}
  Q_INVOKABLE void setExerciseDuration(int i){m_msg.setExerciseDuration(i);}
  Q_INVOKABLE void hideOverlay();
  Q_INVOKABLE void unhideOverlay();

public slots:
  void checkActive();

  // Q_SCRIPTABLE Q_NOREPLY void show();
  // Q_SCRIPTABLE Q_NOREPLY void exit();
  Q_SCRIPTABLE Q_NOREPLY void checkOverlay();

signals:
  Q_SCRIPTABLE void overlayRunning();

private:
  void showOverlay();

  QQuickView *m_overlayView;
  bool m_overlayActive;
  Message m_msg;		  

private slots:
  // void onPackageStatusChanged(const QString &package, int status);
};

#endif // VIEWHELPER_H
