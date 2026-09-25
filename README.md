# SERVER FINDER

Script Luau para executor Roblox, criado por **mateus_15600**.

## Recursos

- Interface com abas laterais: Buscar, Chat Bot, Scripts e Configs, com Info no cabeçalho
- Aba Configs com dez temas visuais, lista rolável e salvamento automático da escolha
- Janela arrastável, minimizável e com avatar do criador
- Tela de carregamento personalizada com saída manual e fallback anti-travamento
- Liberação do painel somente após confirmar o follow do criador
- Busca de servidores e tentativa de teleporte
- Filtro BR que tenta confirmar o país do servidor antes do teleporte
- Busca aleatória e BR que excluem servidores públicos onde seus amigos estão
- Blacklist temporária de servidores que falharam
- Consulta de usuário com selo azul, presença online e Brookhaven
- Chatbot local apenas conversacional, sem iniciar teleporte

## Arquivo principal

- [server_finder_tabs_chat.lua](./server_finder_tabs_chat.lua)

## Observações

- O botão English Server fica desativado porque a API pública de listagem não informa a região ou o idioma real do servidor.
- O filtro Servidor BR consulta o endpoint de junção do Roblox e uma API de geolocalização para confirmar o país. Se o Roblox responder HTTP 401 nessa consulta, o script escolhe o servidor elegível com menor latência e identifica o resultado como estimado; ele não apresenta essa estimativa como confirmação exata.
- Antes de escolher um servidor público, o script consulta a lista e a presença dos amigos e repete a validação logo antes do teleporte. Se não conseguir validar a consulta, interrompe a busca em vez de selecionar um servidor sem verificar.
- O loading verifica se o jogador segue `mateus_15600`. Se ainda não seguir, mostra o perfil e mantém as funções bloqueadas até uma nova verificação confirmar o follow. O popup de atualizações só aparece depois que essa verificação libera o painel.
- A aba Scripts permanece reservada para scripts personalizados que serão adicionados em breve.
- A aba Configs oferece os temas Midnight, Ocean, Emerald, Sunset, Troll, Doido, Colorido, Louco, Erros Fakes e Clássico Windows. O tema escolhido é salvo
  em `ServerFinder_Config.json` com `writefile` e carregado automaticamente na próxima execução.
  Em executores sem suporte a `writefile`, o tema continua valendo durante a sessão atual.
- O ícone do Discord usa PNG estático e fallback de asset local quando o executor não aceita URLs externas em `ImageLabel`.
- A busca pede confirmação antes de iniciar qualquer teleporte, com opções para cancelar ou continuar.
- A busca de usuário verificado exige um username específico.
- O usuário precisa estar online em um servidor de Brookhaven no momento da consulta.
- A busca por usuário verificado é explícita e continua indo para o servidor desse usuário; o filtro de amigos se aplica às buscas BR e aleatória.
- O executor precisa suportar requisições HTTP GET e POST. A busca de amigos usa POST em `presence.roblox.com`; o filtro BR tenta usar o POST em `gamejoin.roblox.com`. Esse endpoint pode exigir autenticação e responder HTTP 401; nesse caso o script usa a menor latência disponível como estimativa, sem exibir o 401 bruto.
- A verificação de follow consulta `friends.roblox.com/v1/users/{userId}/followings` com paginação de até 100 itens por página e para assim que encontra o criador; não depende de cookie ou token do Roblox.
- Este script foi feito para um ambiente de executor Luau, não para Roblox Studio.

Use por sua conta e respeite as regras do Roblox e do executor utilizado.
