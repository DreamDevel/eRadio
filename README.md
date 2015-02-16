# eRadio
**A minimalist and powerfull radio player for elementary OS** 

 ```
Project is under development. Please report bugs or create pull requests after the version 2.0 is released. 
``` 

![](http://i.imgur.com/sdgOr1s.png)
*Screenshot of daily build, not final product.*

Visit our webpage for more info : http://www.dreamdevel.com/apps/eradio

```Note: Web page under construction```

##Install Build Dependencies

**For elementary OS Freya and other ubuntu based distributions** 

```
sudo apt-get install valac libgtk-3-dev libgranite-dev libsqlite3-dev libgee-dev libnotify-dev libjson-glib-dev libsoup2.4-dev libxml2-dev libsqlheavy-dev make cmake
```

**Note for ubuntu based distributions**

You may need to include elementary OS repository for the latest libgranite library 
```
sudo add-apt-repository ppa:elementary-os/stable
```

##Build & Run

**If you are using Sublime Text 3**

* Open eradio.sublime-project with sublime
* Go to menu Tools -> Build System -> Vala/Cmake
* Run ctrl+b to build the project
* Navigate via terminal to build directory and run 'sudo make install' (1 time only)
* Run ctrl+shift+b to run the project

**If you are using the terminal - The simple way**

* Run **. dev-shell** in the tools directory to add tools to your $PATH
* Run **build** from any directory to build the project
* Navigate via terminal to build directory and run 'sudo make install' (1 time only)
* Run **run** from any directory to run the project

**If you are using the terminal - The normal way**

* Navigate to the **build** directory
* Run **cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make** to build the project
* Navigate via terminal to build directory and run 'sudo make install' (1 time only)
* Run **./eradio** to run the project

## Installation

After you build the project run **sudo make install** from the **build** directory