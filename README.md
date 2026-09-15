# SERVER FINDER

Script Luau para executor Roblox, criado por **mateus_15600**.

## Recursos

- Interface com abas laterais: Buscar, Chat Bot e Scripts, com Info no cabeçalho
- Janela arrastável, minimizável e com avatar do criador
- Tela de carregamento personalizada com saída manual e fallback anti-travamento
- Liberação do painel somente após confirmar o follow do criador
- Busca de servidores e tentativa de teleporte
- Filtro BR com resolução da região do servidor antes do teleporte
- Blacklist temporária de servidores que falharam
- Consulta de usuário com selo azul, presença online e Brookhaven
- Chatbot local apenas conversacional, sem iniciar teleporte

## Arquivo principal

- [server_finder_tabs_chat.lua](./server_finder_tabs_chat.lua)

## Observações

- O botão English Server fica desativado porque a API pública de listagem não informa a região ou o idioma real do servidor.
- O filtro Servidor BR consulta o endpoint de junção do Roblox e uma API de geolocalização para confirmar o país. Ele não faz fallback para um servidor estrangeiro quando essa consulta falha.
- O loading verifica se o jogador segue `mateus_15600`. Se ainda não seguir, mostra o perfil e mantém as funções bloqueadas até uma nova verificação confirmar o follow.
- A aba Scripts permanece reservada para scripts personalizados que serão adicionados em breve.
- O ícone do Discord usa PNG estático e fallback de asset local quando o executor não aceita URLs externas em `ImageLabel`.
- A busca pede confirmação antes de iniciar qualquer teleporte, com opções para cancelar ou continuar.
- A busca de usuário verificado exige um username específico.
- O usuário precisa estar online em um servidor de Brookhaven no momento da consulta.
- O executor precisa suportar requisições HTTP GET e POST. O filtro BR depende de POST no endpoint `gamejoin.roblox.com`; se o executor bloquear esse endpoint, a interface mostra o motivo e não promete um servidor brasileiro.
- A verificação de follow usa POST em `friends.roblox.com/v1/user/following-exists`, enviando `targetUserIds`; o script não força o follow, apenas verifica o estado retornado pela API. O executor precisa oferecer uma função `request`/`http_request` para enviar POST.
- Este script foi feito para um ambiente de executor Luau, não para Roblox Studio.

Use por sua conta e respeite as regras do Roblox e do executor utilizado.
