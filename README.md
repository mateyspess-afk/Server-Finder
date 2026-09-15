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
- O filtro Servidor BR tenta confirmar o país pelo endpoint de junção do Roblox e por uma API de geolocalização. Como esse endpoint pode exigir autenticação, quando a confirmação não está disponível ele escolhe o servidor público mais cheio e avisa que a região não foi confirmada.
- O loading verifica se o jogador segue `mateus_15600`. Se ainda não seguir, mostra o perfil e mantém as funções bloqueadas até uma nova verificação confirmar o follow.
- A aba Scripts permanece reservada para scripts personalizados que serão adicionados em breve.
- O ícone do Discord usa PNG estático e fallback de asset local quando o executor não aceita URLs externas em `ImageLabel`.
- A busca pede confirmação antes de iniciar qualquer teleporte, com opções para cancelar ou continuar.
- A busca de usuário verificado exige um username específico.
- O usuário precisa estar online em um servidor de Brookhaven no momento da consulta.
- O executor precisa suportar requisições HTTP GET e POST. Se o executor bloquear o POST no endpoint `gamejoin.roblox.com`, a interface usa o servidor mais cheio como aproximação em vez de ficar sem resultado.
- A verificação de follow consulta `friends.roblox.com/v1/users/{userId}/followings` com paginação de até 100 itens por página e para assim que encontra o criador; não depende de cookie ou token do Roblox.
- Este script foi feito para um ambiente de executor Luau, não para Roblox Studio.

Use por sua conta e respeite as regras do Roblox e do executor utilizado.
