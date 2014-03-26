#!/usr/bin/env perl

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use strict;
use warnings;
use WWW::Mechanize;
use HTML::TokeParser;
use File::Basename;

my $destination = '/home/victor/Wallpapers/ngpod/';
my $symlink     = '/home/victor/Wallpapers/natgeo';

#create a new instance of mechanize
my $agent = WWW::Mechanize->new();
#get the page we want.
$agent->get("http://photography.nationalgeographic.com/photography/photo-of-the-day/");
 
#supply a reference to that page to TokeParser
my $stream = HTML::TokeParser->new(\$agent->{content});
#^^ this is a reference
my $c = 0;#to store the count of images and give the images names
#loop through all the divs
 
while(my $tag = $stream->get_tag("div"))
{
    # $tag will contain this array => [$tag, $attr, $attrseq, $text]
    #get the class of the div tag from attr
    my $cls = $tag->[1]{class};
    #we're looking for div's with the class primary_photo
    if($cls && $cls eq "primary_photo") {
        #get the content of the src tag
        my $imgINeed = 'http:' . $stream->get_tag('img')->[1]{src};
        # Create a file name
        my $fileName = basename($imgINeed);
        #create a new mechanize to download the image
        my $imgDown = WWW::Mechanize->new();
        #give the image url and the local path to mechanize
        $imgDown->get($imgINeed, ":content_file" => $destination.'/'.$fileName );

        # delete the existing symlink, if any
        unlink($symlink);
        # create a symlink to the current picture
        symlink($destination.$fileName, $symlink);

        #update the count
        $c++;
    }
}
#print "Total images scraped $c\n";
