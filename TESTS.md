# SassMeister Tests #

Each block of SCSS should return valid CSS with no warnings or errors when tested against it's respective extension.


## Blend Modes ##

    @import "blend-mode";

    .multiply {
        background-color: blend-multiply(#7FFFD4, #DEB887);
    }


## Bourbon ##

    @import "bourbon/bourbon";

    box:hover {
      @include animation-name(scale, slide);
      @include animation-duration(2s);
      @include animation-timing-function(ease);
      @include animation-iteration-count(infinite);

      // Animation shorthand works the same as the CSS3 animation shorthand
      @include animation(scale 1.0s ease-in, slide 2.0s ease);
    }


## Breakpoint ##

    @import "breakpoint";

    // create $breakpoint variables like so
    // assume min-width (by default) if only a number
    $breakpoint-medium-width: 500px;
    $breakpoint-medium-width-em: 30em;

    .foo {
      @include breakpoint($breakpoint-medium-width) {
        content: 'medium widths';
      }
    }
    .bar {
      @include breakpoint($breakpoint-medium-width-em) {
        content: 'medium widths measured in ems';
      }
    }

    // You can use breakpoint without variables too.
    .rhcp {
      @include breakpoint(30em 40em) {
        content: 'between 30 and 40ems';
      }
    }

## Breakpoint Slicer ##

    @import "breakpoint-slicer";

    $slicer-breakpoints: 0 400px 600px 800px 1050px;

    .element {
      @include at(2) {
        background-color: red;
      }

      @include at(4) {
        background-color: blue;
      }
    }


## Breakup ##

    @import "breakup";

    $breakup-included-blocks: ('basic' 'thin' 'wide' 'full');

    $breakup-breakpoints: (
      'thin' '(max-width: 35.999em)',
      'wide' '(min-width: 36em)',
      'full' '(min-width: 61em)'
    );

    @include breakup-block('basic') {
      .component { background-color: red; }
    }

    @include breakup-breakpoint('thin') {
      .component { background-color: blue; }
    }

    @include breakup-breakpoint('wide') {
      .component { background-color: green; }
    }


## Color Schemer ##

    @import "color-schemer";

    $primary: cs-primary();
    $secondary: darken(cs-secondary(), 10%); // too light, darkening this up a bit.
    $tertiary: cs-tertiary();
    $quadrary: cs-quadrary();

    .primary {
      color: $primary
    }

    .secondary {
      color: $secondary
    }

    .tertiary {
      color: $tertiary
    }

    .quadrary {
      color: $quadrary
    }


## Compass ##

    @import "compass";

    #wrapper {
      @include columns(20em 2);
    }


## Compass Slideshow ##

    @import " css-slideshow";

    .slideshow {
      @include slideshow;
    }


## Fancy Buttons ##

    @import "fancy-buttons";

    button {
      @include fancy-button-structure(26px, 1em, 4px);
      @include fancy-button-colors(#124c89, adjust-hue(#124c89, -120), darken(adjust-hue(#124c89, -120), 6));
    }


## Fittext ##

    @import "fittext";

    h1 {
      font-size: 6em; // For browsers that don't support media queries.
      @include fittext($min-media: 200px, $max-media: 1400px, $min-font-size: 5em, $max-font-size: 50em, $media-increment: 100, $font-increment: 1.5, $ratio: 1, $round: false);
    }


## Foundation ##

    $include-html-classes: false;
    $include-html-tooltip-classes: true;
 
    $tooltip-bg: #000;
    $default-float: left;
    $primary-color: #444;
    $global-radius: emCalc(20);
 
    @import "foundation/components/global";
    @import "foundation/components/tooltips";


## Grid Coordinates ##

    $grid-columns: 12;
    $grid-width: 60px;
    $grid-gutter-width: 20px;

    @import "grid-coordinates";

    @include grid-coordinates;


## Harsh ##

    @import "harsh";

    .random {
      @include harsh();
    }

    .background-color {
      @include harsh(white, rgb(200,50,50), .95);
    }

    .bright {
      @include harsh(random, white, .05);
    }

    .dull {
      @include harsh($transparency: .95);
    }

    .specify-colors {
      @include harsh(#FF0000 blue rgb(50,200,50));
    }

    .horizontal {
      @include harsh($angle: top);
    }

    .angled {
      @include harsh($angle: -32deg);
    }

## Compass Inuit ##

    @import "compass-inuit";

    html{
        font:1em/1.5 Georgia, serif;
        padding:5%;
        background-color:#fff;
        color:#333;
    }
    body{
        max-width:480px;
        margin:0 auto;
    }


## Jacket ##

    @import "jacket";

    $jacket: track, overcoat, mod ".triumph";

    .cafe-race {
      /* Universal */
      font-size: 1rem;

      /* jacket(track, tie, suit) */
      @include jacket(track, tie, suit) {
        position: absolute;
      }
      /* jacket(suit, mod, overcoat) */
      @include jacket(suit, mod, overcoat) {
        top: 3em;
      }
      /* jacket(leather) */
      @include jacket(leather) {
        position: fixed;
      }
    }


## Modular Scale ##

    @import "modular-scale";

    .lace {
      width: ms(7, 16px, golden() fourth() );
    }


## Neat ##

    @import "bourbon/bourbon";
    @import "neat/neat";

    section {
      @include outer-container;
      aside { @include span-columns(3); }
      article { @include span-columns(9); }
    }


## Normalize ##

    $legacy-support-for-ie6: false;
    $legacy-support-for-ie7: true;

    @import "normalize";


## Photoshop Drop Shadow ##

    @import 'photoshop-drop-shadow';

    // Simple shadow
    div.box-shadow {
      @include photoshop-drop-shadow(120, 5px, 0, 5px, rgba(#000, 0.75));
    }

    // Inner shadow
    div.inner-box-shadow {
      @include photoshop-inner-shadow(120, 5px, 0, 5px, rgba(#000, 0.75));
    }

    // Supporting multiple shadows
    div.multiple-box-shadow {
      @include box-shadow(
        photoshop-shadow(120, 5px, 0, 5px, rgba(#000, 0.75)),
        photoshop-shadow(120, 5px, 0, 5px, rgba(#000, 0.75), inset)
      );
    }

    // Multiple Text Shadow
    h2 {
      @include text-shadow(
        photoshop-text-shadow(120, 5px, 0, 5px, rgba(#000, 0.75)),
        photoshop-text-shadow(-60, 5px, 0, 5px, rgba(#300, 0.75))
      );
    }


## Responsive Calculator ##

    @import "rwdcalc";

    .foo {
      margin: rwdcalc(10 10px 13 1em, 960);
    }


## Responsive Sass ##

    @import "responsive-sass";

    .block {
      @include mobile-landscape(960, 240, "/images/high-res.png");
    }


## Salsa ##

    @import "salsa";

    // Nested grids AG test
    .e1 { @include grid(2); }
    .e2 { @include grid(6 container); }
    .e3 { @include grid(2); }
    .e4 { @include grid(3/6); }
    .e5 { @include grid(3/6); }
    .e6 { @include grid(2/6); }
    .e7 { @include grid(4/6 container); }
    .e8 { @include grid(2/4); }
    .e9 { @include grid(2/4); }
    .e10 { @include grid(100%); }



## Sassy Buttons ##

    @import "sassy-buttons";

    .red { @include sassy-button-gradient("matte", #e86a43); }

    .blue { @include sassy-button-gradient("simple", #4d8ccd); }

    .green { @include sassy-button-gradient("glass", #8cbe5f); }


## Sassy Math ##

Sassy Math has been removed from SassMeister for technical reasons.

    $fraction: 2.5;

    $fraction-2: to-fraction(2.5);

    #tester {
      numerator: numerator($fraction);
      denominator: denominator($fraction);
      to-fraction: to-fraction($fraction);
      to-decimal: to-decimal(3/2);
      exponent: exponent(8, 2, 3);
      power: power(20, pi());
      sqrt: sqrt(16129);
      nth-root: nth-root(27, 3);
      factorial: factorial(9);
      pi: pi();
      e: e();
      ln: ln(e());
      log10: log10(10);
      golden: golden-ratio();
      is-int: is-int(4);
      is-float: is-float(2);
    }


## Sassy Text Shadows ##

    @import "compass";
    @import "sassy-text-shadow";

    body {
      text-align: center;
    }

    h1 {
      @include text-shadow(sassy-text-shadow(#BADA55));
      line-height: 8em;
    }

    h2 {
      @include text-shadow(sassy-text-shadow(#BADA55, 100, 80, 120, 90, -45, 0.09));
      line-height: 8em;
    }

    h3 {
      @include text-shadow(long-shadow(30, #BADA55, 25, 0));
      line-height: 8em;
    }

## Singularity.gs ##

    @import "singularity";

    $grids: 1 3 5 7 9;
    $gutters: 1/3;

    // Simplifies use of $options for Isolation Output Style
    #foo {
      @include grid-span(2, 3, $output-style: 'isolation', $options: 'both');
    }
    #foo {
      @include isolation-span(2, 3, 'both');
    }

    // You can also pass in $grid and $gutter
    #bar {
      @include grid-span(2, 3, (2 8 2 1), .25, 'isolation');
    }
    #bar {
      @include isolation-span(2, 3, $grid: (2 8 2 1), $gutter: .25);
    }

    #baz {
      @include grid-span(2, 3, (2 8 2 1), .25, 'right');
    }
    #baz {
      @include isolation-span(2, 3, 'right', (2 8 2 1), .25);
    }


## Singularity Extras ##

    @import "singularity-extras";

    $grids: 3;
    $grids: add-grid(1 2 3 at 500px);
    $grids: add-grid(ratio(golden(), 3) at 700px);
    $grids: add-grid(ratio-spiral() at 900px);
    $grids: add-grid(compound(2, 3, 4) at 1100px);

    $gutters: .5;

    #layouts {
      content: 'Initial Layout';
      @include grid-span(1, 2);

      @include layout(6, .25, 'float') {
          content: 'Inner Layout';
          @include grid-span(1, 2);
        }

      @include breakpoint(500px) {
        @include layout(6, .25, 'float') {
          content: 'Inner Layout, Breakpoint';
          @include grid-span(1, 2);

          @include layout(2 4 6) {
            @debug find-grid();
            content: 'Nested Layout';
            @include grid-span(1, 2);
          }
        }
      }
    }


## Stipe ##

    @import "stipe/manifest";
    @import "stipe/grid/extends";

    .form_control {
      @include grid(4);

      &:last-child {
       @include grid(4.125, omega);
      }
      &:first-child {
        @include grid(4.125, alpha);
      }

      & button[type=submit] {
        display:block;
        margin: 1.2em auto;
      }
    }


## Stitch ##

    @import 'stitch';

    body {
        @include sans-serif('Avenir');
    }

    #logo {
        @include enable-hardware-acceleration
    }


## Susy ##

    @import "susy";

    .ag1 { @include span-columns(2,10); }
    .ag2 { @include span-columns(6,10); }
    .ag3 { @include span-columns(2 omega, 10); }
    .ag4 { @include span-columns(3,6); }
    .ag5 { @include span-columns(3 omega,6); }
    .ag6 { @include span-columns(2,6); }
    .ag7 { @include span-columns(4 omega,6); }
    .ag8 { @include span-columns(2,4); }
    .ag9 { @include span-columns(2 omega,4); }
    .ag10 { clear: both; }


## Toolkit ##

    @import "toolkit";

    .ratio-16-9 {
      @include intrinsic-ratio;
    }

    .ratio-4-3-75 {
      @include intrinsic-ratio(4/3, 75%);
    }

    .ratio-7-8-75-iframe-no-extend {
      @include intrinsic-ratio(7/8, 75%, 'iframe', false);
    }

## Zen Grids ##

    @import "zen";

    .content {
      @include zen-grid-item(4, 3); // Make this grid item span 4 columns. // Position this grid item in the 3rd column.
    }

    .aside2 {
      @include zen-grid-item(1, 7);
    }

    .footer1 {
      @include zen-clear(); // Apply this mixin to start a new row.
      @include zen-grid-item(3, 5);
    }
    .footer2 {
      @include zen-grid-item(4, 1);
    }
