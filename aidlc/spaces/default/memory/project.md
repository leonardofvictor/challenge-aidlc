# Project-Level Rules

> Project-specific specialisation and corrections. Loaded after `org.md` and
> `team.md` as strict-additive guidance; contradictions with broader policy
> are rejected. Populated by practices-discovery and the self-learning loop.
>
> Use sparingly: most teams don't need a project layer. Reach for it
> only when this specific project needs stable, durable guidance beyond the
> team practice (for example, package-specific release checks or an additional
> regression suite for a legacy component).

## Way of Working

<!-- Project-specific specialisation. Example: -->
<!-- This monorepo requires package-scoped branch names and a package owner -->
<!-- review in addition to the team's normal merge policy. -->

## Walking Skeleton

<!-- Project-specific specialisation. Example: -->
<!-- The walking skeleton must exercise the legacy service adapter as well -->
<!-- as the new service boundary. -->

## Testing Posture

<!-- Project-specific specialisation. -->

## Guard Policy

<!-- Project-specific. Mode: strict, relaxed, or off. Strict here holds for every intent and cannot be changed from chat. A section under the retired Change Control heading, written by an earlier release, is still read. -->

## Deployment

<!-- Project-specific specialisation. -->

## Code Style

<!-- Project-specific specialisation. -->

## Tech Stack

<!-- Technology choices locked for this project. -->

## Decided

<!-- Decisions made in earlier stages that should not be re-asked. -->
<!-- Format: DECIDED: [decision] (Stage [slug], [date]) -->

## Scope Overrides

<!-- Custom scope rules for this project. -->

## Forbidden

<!-- Populated by practices-discovery affirmation gate. -->
<!-- Format: NEVER [behavior] (affirmed [date]) -->
<!-- Example: NEVER throw exceptions across service layer boundaries (affirmed 2026-05-17) -->

## Mandated

<!-- Populated by practices-discovery affirmation gate. -->
<!-- Format: ALWAYS [behavior] (affirmed [date]) -->
<!-- Example: ALWAYS use Result<T,E> for fallible operations in service layer (affirmed 2026-05-17) -->

ALWAYS tratar como contrato comum entre o jogo Battle Knights e a camada de som exatamente oito eventos, com estes identificadores: `GAME_START` (o jogo mostra o tabuleiro e os itens; sugestão: tema de abertura), `MOVE` (um cavaleiro anda uma casa; passo curto), `DROWN` (um cavaleiro sai do tabuleiro e se afoga; som descendente), `PICK_UP` (um cavaleiro encontra um item na casa; notas rápidas subindo), `DROP_ITEM` (um cavaleiro descarta o item de menor valor; uma nota grave), `ATTACK` (um cavaleiro entra na casa de outro; batida forte e a música muda para combate), `DEFEAT` (um dos cavaleiros perde o combate; acorde triste) e `GAME_END` (o jogo mostra o resultado final; tema de encerramento) (affirmed 2026-10-04)
ALWAYS emitir esses eventos a partir da lógica do jogo e conferir nos testes quais eventos foram disparados, sem depender de ouvir o som (affirmed 2026-10-04)
ALWAYS conferir esta lista com o que o código do jogo realmente faz durante o estudo do jogo (Reverse Engineering) e levar qualquer diferença (evento a mais, a menos ou com outro nome) a um ponto de aprovação humano, em vez de alterar a lista por conta própria (affirmed 2026-10-04)
ALWAYS limitar a música de fundo a três climas: exploração, combate e encerramento; os sons sugeridos são só sugestão e os identificadores dos eventos são o contrato (affirmed 2026-10-04)

## Corrections

<!-- Project-specific corrections from human feedback. -->
<!-- Format: NEVER/ALWAYS [behavior] (learned [date]) -->
