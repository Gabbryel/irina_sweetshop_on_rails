require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")

import "bootstrap";

import { sections } from './category_show_sections'
import { animateCard } from './category_hover_animation'
import { showStandardDesign } from './standard_design'

sections()
animateCard()
showStandardDesign()