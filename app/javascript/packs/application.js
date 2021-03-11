require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")

import "bootstrap";

import { sections } from './category_show_sections'
import { animateCard } from './category_hover_animation'
import { showStandardDesign } from './standard_design'
import { renderSquares, renderSquaresResize } from './homepageJS/squares_render'
import { vh, vhOnResize } from "./vh";
import { showLinks } from './categoryCardLinks';


sections()
animateCard()
showStandardDesign()
renderSquares()
renderSquaresResize()
vh()
vhOnResize()
showLinks()

