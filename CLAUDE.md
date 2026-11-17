# CLAUDE.md

SQL that builds a NoHarm database: `noharm-public.sql` (the `public` schema: shared tables, types and the trigger functions), `noharm-create.sql` (a hospital schema, as `demo`; `-aghuse`, `-cpoe`, `-regulation` variants), `noharm-triggers.sql` (each schema's trigger functions and triggers, which call the `public` functions), `noharm-insert.sql`, `noharm-newuser.sql` and `noharm-test.sql`. CI (`.github/workflows/build.yml`) loads them in that order into PostgreSQL; the `admin` repository's test setup (`scripts/setup-test-db.sh`) loads the same files.

## Don't comment the SQL files

Don't add comments to the `.sql` files to explain where a rule is used elsewhere or what depends on it. Write it here instead.

## Rules copied in other repositories

Change these together with the copy, in the same change.

### `public.complete_presmed_v2`: frequency, converted dose, outlier and score

The `backend-private` repository's score link (`lambda_scores.link_segment_scores`, in `repository/score_link_repository.py`; the admin's Gerar Scores runs it after a segment's scores are generated) recalculates an item's `frequenciadia` and `doseconv` and links it to an outlier with a copy of these rules of `complete_presmed_v2`:

- `frequenciadia`: the `frequencia` table's value for `fkfrequencia` (else the value the PEP sent); without `fkfrequencia`, `sletapas`, then `horario` by origin (`Medicamentos`: times of the day, `ACM` 44, `SN` 33; `Soluções`: count of `das`), then `slacm = 'S'` for `Soluções` (44), else 99; a split dose (`dose_diferenciada` with `dose` 0) is once a day; in an AGHUSE schema (`schema_config.tp_pep`) the frequency code (`8H`, `2D`, `3S`, `30M`, `4X`) wins over all of these
- `doseconv`: the dose (or the sum of the split dose) times the `unidadeconverte` factor of the item's segment, then rounded up to the `medatributos` divisor (per kilo of `pessoa.peso` when `usapeso`)
- outlier: the exact `outlier` of the drug, segment, rounded `doseconv` and `frequenciadia`, else the closest one (cosine, then euclidean distance; `aprox`), and its score (`escoremanual`, else `escore`)

Changing any of these? Change `repository/score_link_repository.py` and `tests/test_score_link_db.py` in `backend-private` too (see the "Linking a segment's items to its scores" section of its `CLAUDE.md`).

### `public.organizacao` and `public.organizacao_schema`: the schemas of an organization

`organizacao_schema` has one row per schema (`schema_name` is the key, so a schema belongs to at most one organization) with the friendly name (`nome`) the app's schema picker shows. The `admin` repository writes them (page Organizações, `services/organization_service.py`) together with the `ORGANIZATION_MANAGER` grant in `usuario_extra.config['organization']` (`{"id": idorganizacao, "allSchemas": bool}`); the `backend` repository reads them at login to give an `allSchemas` manager every schema of the organization (`repository/organization_repository.py`). The seed's `Organização Demo` (`demo`, `teste`) is used by both repositories' tests.

Changing these tables? Change the models in `admin` (`backend/models/organization.py`) and `backend` (`models/appendix.py`) too. In production the users of both APIs need `SELECT` on both tables, and the admin's also `INSERT, UPDATE, DELETE` (plus `USAGE` on `organizacao_idorganizacao_seq`).
