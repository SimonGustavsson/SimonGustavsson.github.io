I grew up in the MySpace era of customizing my page using copy-pasted HTML+CSS (R.I.P \<marquee /\>), and once I came across PHP and saw that by typing just a few lines of magic I could fill an entire page I was **hooked**.

```
for ($i \= 1; $i \<= 6; $i++) {
    echo "\<h{$i}\>Heading {$i}\</h{$i}\>\\n";
}
```

I went on to officially study programming and immediately got thrusted into a world of pointers and pointers to pointers, … to pointers (where half my class failed). Through sheer force of will (read: stubbornness) I persisted, and later moved into C\# that was a pivotal point where I moved from “learning English” to “learning **in English**” (my place of study had no Swedish books yet on C\#).

```
namnrymd HejVärlden {
    klass Program {
        statisk tom Main() {
            Konsol.SkrivRad("Hej världen\!");
        }
    }
 }
```

(16 year old Simon would’ve been thrilled to try [sevass](https://marketplace.visualstudio.com/items?itemName=Salmon.sevassvsc))

In the years that followed, I took a hiatus from programming while I amassed a huge wealth of knowledge and skills in the art of World of Warcraft before returning to dust off my skills and creating a suite of productivity tools that made my life as a gamer easier

In 2011, I took the plunge and moved from Sweden to England and joined a fantastic little company called [DriveWorks](https://www.driveworks.co.uk) where I continued on the Microsoft stack and delved into design patterns, [VB.NET](http://VB.NET), TypeScript, interfacing with other products through their APIs (SolidWorks, ePDM, …) while building some really neat Design Automation software. Being a spry 20-something year old with way too much time on my hands I spent most evenings and weekends reading, researching, and writing software that was outside of the domain of my employer at the time.

As someone that has always relentlessly pursued answers and demanded to know “how things work” (sorry for all the “Why?”s, mom\!), I was **pumped** when the Raspberry Pi 1 came out, immediately bought one and started hacking away at ARM assembly bending that tiny embedded LED to my will. Once assembly became too cumbersome and I started writing more C, what started out as 10 lines of assembly quickly grew over the coming years, a driver for reading from the SD card here, a display driver to render a console there, down to a full USB stack with keyboard & mouse support.

```
\_start:
ldr r0,=BASE
ldr r1,=SET\_BIT3
str r1,\[r0,\#GPFSEL2\]
ldr r1,=SET\_BIT21
str r1,\[r0,\#GPSET0\]
```

In 2017, I once again took a huge plunge. This time moving from England all the way across the pond to the good ‘ol US of A to be with my (now) wife. I stayed at DriveWorks as their first (and at the time only) remote software engineer until 2019 when I was ready to take on a brave new challenge in another domain.

Entering, HubSpot \- it was a **massive** change and an extremely satisfying learning curve moving from Windows desktop software to working on a large SaaS product. From working ‘full stack’ creating delightful UX on desktop (and web) all the way down to the database layer \- to designing data intensive pipelines that processed tens of thousands of events per second as a primarily backend software engineer. The code I wrote moved from “gets into customers hands a few times per year” to “A few times **per day**”. Some of the big changes:

* **Quick iterations**; equally thrilled and a huge responsibility knowing that any little tweak I made had the potential to disrupt real humans as they tried to get on with their day.
* **Large data;** when your software is based on “each customer has their own local database on their machine” you can really optimize the database for your use case and as long as your app runs well \- all is great\! In the world of SaaS and multitenancy you’re immediately exposed to a lot of new fun concepts like hotspotting, noisy neighbors, load balancers, circuit breakers, and many many more patterns and challenges.
* **Responsibility delineation;** what customers use \- an API that returns a response a reasonable amount of time; what they don’t see:
  * Large scale data processing pipelines that work behind the scenes in eventually consistent systems
  * Backfill jobs to patch old tables as new functionality is added that can take multiples of days to complete
* ..and much much more.

Over time, the itch to just write some code™️in my spare time returned, which coincided with me being fortunate enough to be able to buy a whole house with my wife. I’ve always loved the idea of connecting software to the physical world so it should come as no surprise that the world of IoT had caught my attention\!

* Do I, install Home Assistant (or IFTTT/Homebridge/Homey/Hubitat/OpenHAB/Apple home/…)? Of course not, the itch is to write some code™️, not spend my evenings trying to debug yaml.
* Do I, create a web app that displays various stats gathered from sensors around my house? Of course not, I create a drag and drop dashboard builder where I can build `n` dashboards (one for each room where I want it) with click, navigate, modal popup etc support.
* Do I, run a background process to provide automations (“At 17:30 turn on Dining Room lights”)? Of course not, I create a workflow engine with a visual editor where you can map out all of the states you want, connect them together with conditions and actions that get executed when entering a state.
* Do I, install libraries so that I can interface with the various IoT devices I have my eye on? Of course not, I scour the web for the HAP specification and build an entirely custom implementation.

{{ limha.png Screenshot here }}

The home automation system I’d built ran on my laptop for the longest time, before I graduated to running it on a single Intel NIC. These days, the system runs on a multi-node k3s cluster in a server rack in my house with 8 VMs serving as my k3s backbone, and lots of other small little goodies running alongside it. Now that we’re introducing kubernetes, we’re once again back to the idea of writing a bunch of yaml and if you recall the section above where I dismissed it, you can probably see where this is going..

The yaml is (mostly) gone, and I’ve been working on a cluster management application that

* Can dynamically provision new Virtual Machines
* Deploy/scale/restart kubernetes deployments
* Operate as a CI server for all of the software I write

…but more on that on the projects page!

So long (for now)

- Simon