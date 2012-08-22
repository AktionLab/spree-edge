spree-edge
==========

Spree playground

Installation
------------

    git clone git@github.com:AktionLab/spree-edge.git
    bundle install
    gem install spree
    spree install --edge
    
Select yes for all options, EXCEPT precompile assets. Select no for that. It'll make life in development easier.

If your system complains about ImageMagick, make sure you've got that library installed:

    sudo aptitude install imagemagick
    
OK, now you should be ready to run your Rails app with Spree:

    rails s
    
Happy shopping.