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

#include "applibrary.h"
#include <QDBusConnection>
#include <QDBusInterface>

appLibrary::appLibrary(QObject *parent) :
  QObject(parent)
{
}


/* Prevents screen going dark during video playback.
   true = no blanking
   false = blanks normally

   Credits to: https://github.com/skvark/SailKino
*/
void appLibrary::setBlankingMode(bool state)
{
  QDBusConnection system = QDBusConnection::connectToBus(QDBusConnection::SystemBus,
							 "system");

  QDBusInterface interface("com.nokia.mce",
			   "/com/nokia/mce/request",
			   "com.nokia.mce.request",
			   system);

  if (state) {
    interface.call(QLatin1String("req_display_blanking_pause"));
  } else {
    interface.call(QLatin1String("req_display_cancel_blanking_pause"));
  }

}
