ROADMAP:

- [ ] Design and implement About page
- [ ] Add notification service
- [ ] Rethink the design of the app (less hacks and more clean code)

## Design

# == widgets folder

## ZikrPageWidget

- it takes: title of zikr
- builds zikr page (notes,content,footer)

## == azkarListView subfolder

### ZikrListViewTile

- it takes: title of zikr, route
- builds zikr list tile.
- TODO: get bookmarks from static class instead of sharedPreferences everytime?
- TODO: better routing handling?

### ZikrOfTheDayTime

- takes: titles, route
- resposible for displaying zikr of the day tile on homescreen with special icon.
- simpler than ZikrListViewTile.

### AzkarListViewWidget

- build tiles of azkar titles
- it needs
  - list of titles
  -

# == Settings folder

## SettingsScreen

## ToggleThemeBtn

## YousriaBeginningDayDropDown

# routes

## Settings

- usees naviagtor.push, not nested

## zikrPageRoute

- handle ZikrPageWidget.

## awradScreen

- '/awradScreen'
- has week,collection,zikr,helia
-
