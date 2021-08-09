# PiProbe
# What is PiProbe?

PiProbe is a Raspberry Pi OS image customized for the purpose of automatically monitoring internet censorship events in a way that’s close to an appliance. Helping guarantee frequent data points for large lists of urls to check.

It's solution that uses OONI, but it's not tied down to a full PC that is on and connected to contribute measurements, doesn't require coordinated volunteers to contribute daily measurements nor makes a phone mostly useless while large lists are tested.

PiProbe is a way to help people anywhere in the world to get accurate and decentralized data regarding online censorship automatically as an appliance. Once set up, just plug the Raspberry Pi to the internet in the target network. 

The goal behind this project is to provide a reliable, fast and simple way of deploying measurement probes that can be installed by anybody without the need of technical skills.  We use software by the Open Observatory of Network Interference (OONI) and other tools  to transform a simple Raspberry Pi into a powerful censorship monitoring machine.

With PiProbe anyone can contribute evidence of internet censorship and network interference, which can later be analyzed online through the OONI Explorer website. 

TL;DR: This makes it easier to make sure you are producing network measurements at regular intervals automatically on a Raspberry Pi, with little to no interaction.

## Near future plans

Make installation easier for people with no command line experience

## Hardware support
PiProbe has been tested in most recent full-size Raspberry Pi devices, namely: 3B, 3B+ and 4. Other Raspberry Pi versions might work but have not been tested.

## Important disclaimers
Take into account the possible risks of running OONI or any other similar software, it is critical to know the legislation of the country you are using PiProbe. Some governments, especially authoritarian ones, may see the use of OONI and PiProbe as a threat. Use at your own discretion and protect yourself more than anything else.

This is experimental software in development.

The software is provided “as is”, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.


# Installation
To install and run a PiProbe probe you’ll need:
Raspberry Pi Model 3B, 3B+ or 4
A microSD card of at least 4GB (8GB+ recommended)
Internet connection (WiFi or cabled)
PiProbe disk image
A computer running Windows, MacOS or Linux.

Download the .img file with the PiProbe image. Don’t forget to check its authenticity:

'''
md5sum d971f42d0902d68cc2e04f16621d5f61

sha256sum 2d68b3e59f682920220e17bcfa33f1774624554e2b0599bafd0b4bfaef6cbb18

sha512sum 24f96a4a9ad658cf43d1a9c095e87f91ad55fc61de16d022ea54042459c33a3309d4e22b4ebe8111db7c6d1a77f7170145c29f4aa99b524e734ece0697948a03
'''


To install the downloaded image into a Raspberry Pi we recommend using Raspberry Pi Imager, an official utility that helps managing different operating systems and burning them into a microSD. Other methods or softwares can be used to create a bootable drive, but they won’t be covered in our documentation.

It is important to note that when burning an image into a microSD, ALL the data inside the card will be erased and can’t be recovered. Remember to back up all the files inside the SD card before continuing.  

After installing Raspberry Pi Imager, open the utility and when choosing an OS select “Use custom” from the list. Browse for the recently downloaded PiProbe image in your computer files and select it.

Now insert the microSD card into your computer and choose it from the storage list in the Raspberry Imager. At this point it is possible to further customize the image by pressing ctrl+shift+x to open the advanced options menu, where the hostname for the Raspberry Pi can be changed or even set up a WiFi network for the probe to use. After this proceed to press “Write”.


 

Note: SSH it’s already enabled by default in the PiProbe image.

After the image is burned into the microSD card, remove it from the PC and insert it into the Raspberry Pi. Then plug in the RPi to a power source and connect it to your router via an internet cable (unless you’ll be using a WiFI that you set up using the Raspberry Imager).

Now you can connect to the Raspberry Pi using SSH. The new probe is ready to be configured!

# Initial configuration

Before plugging the power to your Raspberry Pi with PiProbe newly installed:
Decide if you want to connect a monitor and keyboard temporarily or connect through your computer using SSH.
If you will use an ethernet cable to connect to the network, please also connect it at this point
Then, connect the power cable

If you are connecting via SSH, you should find the IP address of the probe in your router (or try piprobe.local as the destination address). If you are unfamiliar with SSH, check this guide.
Also, check this for guidance on how to obtain your probe's local IP address

'''
ssh probe@piprobe.local 
'''
If that didn't work, or multiple are connected, replace "piprobe.local" with the IP address of the target probe.

If you used ssh or a keyboard and monitor, now introduce the default login credentials:
User: probe
Password: internet


There are two main default users in the PiProbe image: user ‘pi’ and user ‘probe’. Both users have the same default password. For security reasons it is critical to change this password for both users, this will be handled by the configuration script.

To start the configuration script, type the following command in the terminal prompt:

'''
sudo ./install.sh
'''

This will run a script that will prompt the user with a series of customizable parameters that can help identify the probe, such as ID and ISP when you are in, it makes your life easier if you have multiple probes. Also, the script will ask the user to establish the behavior and frequency OONI measurements.



After running the script, the system will reboot and the Raspberry Pi will be ready to act as a probe.

How to use OONI manually (opcional)
The Open Observatory of Network Interference (OONI) is a free software project that aims to empower decentralized efforts in increasing transparency of Internet censorship around the world. Since 2012 OONI has been working on a free and open-source software called OONI Probe that anyone can run to measure the blocking of websites or services.

The data collected by OONI Probe can potentially serve as evidence of Internet censorship since it shows how, when, where, and by whom it is implemented.This information is automatically uploaded to the OONI Explorer where anyone can see the test results.

There are two main applications made by OONI in PiProbe: ooniprobe-cli and miniooni.
ooniprobe-cli:
This is the main utility from OONI Probe. It runs several tests, such as looking for censored websites from a list of over 1450 entries, or checking if circumvention tools like Tor are being blocked. The measurement results will be uploaded automatically to OONI's servers. For the full list of tests and their explanations, please refer to OONI’s official website.

'''
ooniprobe run
'''

By default, PiProbe runs ooniprobe-cli once a day at 1:00 am without any interaction, but that can be changed at any time running the initial configuration file install.sh at any time.

miniooni:
With miniooni you can run tests that are far more specific. 

You can test individual websites, 
'''
./miniooni -i https://google.com web_connectivity
'''

Multiple websites
'''
./miniooni -i https://google.com -i https://youtube.com web_connectivity
'''

Or running other tests individually, testing a list of urls or more.
'''
./miniooni -i  web_connectivity
'''



## Risks
# Remote Management

**WARNING: This is heavily discouraged if you don't needed it or are unsure about the risks involved**

Remote management is not enabled nor configured by default. Before you begin, make sure no default passwords are enabled in the probe, that only highly secure passwords are used to login. We recommend requiring an SSH key, preferably one that only exists in secure hardware such as a yubikey.  
## SSH via Tor hidden service
Tor is not installed by default in PiProbe, but If you feel you need an extra layer of anonymity when connecting to your probe, this is for you.

A bash script with all the necessary steps to install Tor is inside the home directory of the ‘probe’ user. Just run it using sudo.

```sudo ./tor-install.sh````



Connect via SSH WITH TOR:

In order to establish an ssh session with a .onion host you must also have the tor and torsocks packages installed on your local host. Or use other configuration to connect to ssh via Tor.

```torsocks ssh probe@abcdefh1234.onion ```
abcdefh1234.onion being yout probes .onion address



## Additional risks of remote management
Remote management opens your probe for third parties to try to brake in into your probe(s), giving them access to not only your probe, but possibly the host network. 
Do not enable any kind of remote management if you don't need it, if you do make sure to model your risks and implement a solution accordingly. 

Making sure probes with remote management can't be accessed by any kind of default password is absolutely critical, and probably not enough. We recommend requiring an SSH key, preferably one that only exists in secure hardware such as a yubikey. 

In some situations the project and hosts of probes can be at risk if the probes know the IP address of a management server and if a server or project members know the IP addresses of the probes, we try to mitigate this risk using Tor, to access probes without keeping a list of IP addresses that can expose their physical location to some parties, also don't use a server for management that can be used to expose the probes in network traffic or if the server is compromised.
