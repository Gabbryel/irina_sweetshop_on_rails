## Architecture

- Rails 7.0.8.3 app (`config/application.rb`) still loads defaults 6.0; expect older conventions and verify initializers before relying on newer defaults.
- Nested, slugged routes in `config/routes.rb` expose categories → recipes/cakemodels and admin dashboards under `/dashboard/*`.

## Domain & Data

- `Category`, `Recipe`, and `Cakemodel` (`app/models`) drive the catalogue; `Cakemodel` links to a `Design`, `ModelComponent` join records (recipe + weight), and `ModelImage` attachments.
- ActionText powers `Cakemodel` rich content (`has_rich_text :content`), so controller updates must permit `:content` and views rely on Trix assets.
- Money-Rails monetises `price_cents` fields (RON default in `config/initializers/money.rb`); keep integer `_cents` columns and permit cents params.
- Active Storage is Cloudinary-backed in all envs (`config/environments/*` + `config/initializers/cloudinary.rb`); local dev needs `CLOUD_NAME`, `CLOUD_API_KEY`, `CLOUD_API_SECRET`.

## Auth & Authorization

- Devise manages users (`app/models/user.rb`); most controllers `before_action :authenticate_user!` except public `index/show`.
- Pundit enforcement in `ApplicationController` requires every action to call `authorize`/`policy_scope` or intentionally `skip_authorization`.
- Admin-only flows use `user.admin` checks inside policies (`app/policies/*`); mirror `isUserAdm?` helpers rather than hand-rolling role guards.
- Static controllers must be whitelisted in `skip_pundit?` (see `PagesController`) to avoid `verify_authorized` failures.

## Content & Assets

- `SlugHelper` (`app/helpers/slug_helper.rb`) runs `after_save :slugify` and re-saves the record; guard against recursive callbacks and ensure `name` is present before save.
- Layout meta tags expect `@page_title`/`@seo_keywords` from `MetaTagsConcern` plus `DEFAULT_META` (`config/meta.yml`); set these when adding pages.
- Views lean on partials in `app/views/partials` and page-specific SCSS under `app/assets/stylesheets/pages`, included by `application.scss`.

## Frontend

- esbuild bundles JS (`package.json`, `esbuild.config.mjs`); register Stimulus controllers through `app/javascript/controllers/index.js`.
- `application.js` loads Turbo, ActionText, Bootstrap, and Stimulus—extend via ES modules; Webpacker remains in dependencies but should be avoided unless verified still needed.
- Run `bin/dev` (Foreman + `Procfile.dev`) to boot Rails on port 3006 with `yarn build --watch` and `sass ... --watch` so asset changes rebuild.

## Cart & Reviews

- `CurrentCartConcern` seeds `session[:cart_id]`; cart/item flows assume an authenticated user can own one cart—preserve this when adding checkout features.
- `ReviewsController` detects `recipe_id` vs `cakemodel_id`, assigns polymorphic `Reviewable`, and sends both user/admin emails via `ReviewMailer` immediately.
- Rating helpers live on models (`overall_rating`, `no_of_ratings`) and filter approved reviews through `RatingsConcern`; keep approval semantics aligned.

## Ops & Workflows

- `db.sh` automates pulling the Heroku backup (`irinasweet`) and restoring into `irina_sweetshop_on_rails_development`; requires Heroku CLI auth and local Postgres.
- Postgres config lives in `config/database.yml`; match DB names when restoring dumps or running CI.
- Deployment uses Puma (`config/puma.rb`) and the root `Procfile`; review before editing concurrency or dyno settings.
- Mailers (`app/mailers/user_mailer.rb`, `review_mailer.rb`) send via `deliver_now` with default sender `comenzi@irinasweet.ro`, admin notifications to `comenzi@irinasweet.ro`.

## QA Notes

- Pagination is via Pagy (default 16 items in `config/initializers/pagy.rb`); include `Pagy::Backend` when introducing new collection actions.
- Bullet boots in development (`config/environments/development.rb`); resolve warnings before committing heavy query changes.
- A `binding.pry` remains in `RecipesController#edit`; strip or guard it when touching that action to avoid halting production-like runs.
