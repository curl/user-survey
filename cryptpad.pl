#!/usr/bin/perl

#
# Generate a question JSON form suitable for import in crytpad.fr
#

# extract all question files and order from the README
my @qs;
open(R, "<README.md");
while(<R>) {
    if($_ =~ /\]\((.*.md)\)/) {
        push @qs, $1;
    }
}
close(R);

my $num = 1;

sub getid() {
    return "i" . $num++;
}

sub getq {
    my ($file) = @_;
    my $head; # header mode
    my $otype;
    my $oq;
    my $op;
    my @oalt; # the alternatives
    open(F, "<$file");
    while(<F>) {
        my $l = $_;
        chomp $l;
        if(/^---/) {
            $head ^= 1;
        }
        elsif($head) {
            my %types = ('check-boxes' => 'checkbox',
                         'radio-buttons' => 'radio',
                         'text' => 'textarea' );
            if($l =~ /^Type: (.*)/) {
                my $itype = $1;
                $otype = $types {$itype};
                if(!$otype) {
                    print "? $itype\n";
                }
            }
        }
        else {
            if(/^# (.*)/) {
                $oq = $1;
            }
            elsif(/^- (.*)/) {
                push @oalt, $1;
            }
            elsif(/^(.*)/) {
                my $q = $1;
                if($q) {
                    $q =~ s/\n/\\n/g;
                    $q =~ s/\"/\\\"/g;
                    $op .= $q;
                }
            }
        }
    }
    if($op) {
        $oq .= " ($op)";
    }
    return ($oq, $otype, @oalt);
}

sub makeq {
    my ($q, $t, @opts) = @_;

    my $id = getid();

    print <<Q
    ,
    "$id": {
      "type": "$t",
Q
        ;
    if($t eq "textarea") {
        print <<OPTS;
      "opts": {
        "maxLength": 2000
OPTS
        ;
    }
    elsif($opts[0]) {
        print <<OO
      "opts": {
        "values": [
OO
            ;
        my $i = 0;
        for my $o (@opts) {
            my $nid = getid();
            my $c = $i++ ? "," : "";
            print <<OPT;
          ${c}{ 
            "uid": "$nid",
            "v": "$o"
          }
OPT
            ;
            
        }
        print <<END;
        ],
        "max": $i
END
      ;     
    }
    print <<Q
      },
      "q": "$q"
    }
Q
        ;

    return $id;
}

sub intro {
    open(I, "<INTRO.md");
    my $j;
    while(<I>) {
        $j .= $_;
    }
    close(I);
    $j =~ s/\n/\\n/g;
    $j =~ s/\"/\\\"/g;
    print <<INTRO;
{
  "form": {
    "intro": {
      "type": "md",
      "opts": {
        "text": "$j"
      }
    }
INTRO
    ;
}


intro();

my @order;
for(@qs) {
    my ($q, $t, @opts) = getq($_);

    push @order, makeq($q, $t, @opts);
}

print <<OO;
  },
  "order": [
    "intro",
OO
;

my $i = 0;
for(@order) {
    my $c = $i++ ? ",\n": "\n";
    print "$c    \"$_\"";
}
print "\n";
print <<OO;
  ],
  "version": 1
}
OO
;
