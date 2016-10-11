<img src="https://github.com/DreamDevel/eRadio/raw/master/images/icons/48x48/apps/eRadio.png" width=48> 
# eRadio #
**A minimalist and powerfull radio player for elementary OS** 

 ```
Project is under development but almost complete (v2.0). You are free to report any bugs or create pull requests. 
``` 
<img src="http://i.imgur.com/YCYgFEw.png">  

##Install Build Dependencies

**For elementary OS Loki and other ubuntu based distributions** 

```
Navigate to project's tools directory via terminal and run ./install-deps
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
