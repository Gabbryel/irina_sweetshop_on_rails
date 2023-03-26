require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")
import "bootstrap";
require("trix")
require("@rails/actiontext")

import { vh, vhOnResize } from "./vh";
import { showStandardDesign } from './standard_design'; //show cake standard design


// import { showLinks } from './categoryCardLinks';
// import easterModal from './homepageJS/easterModal';
// import renderDisclaimerModal from './homepageJS/disclaimerModal';

vh()
vhOnResize()
showStandardDesign()

// animateCard()
// easterModal()
// showLinks()
// renderDisclaimerModal()

