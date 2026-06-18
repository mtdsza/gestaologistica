## Sistema de Gestão Logística

Esse sistema foi desenvolvido para a disciplina de Programação para Dispositivos Móveis I do IF Sudeste MG.
##### Grupo: Dudson, Matheus, Roberto.

## Instruções para uso do sistema
Primeiramente, executar 'flutter pub get' para baixar os pacotes e dependências do projeto.
### Login no sistema:
Por padrão, o sistema pode ser acessado com a conta de adminstrador:\
User: admin\
Senha: admin123\
\
Também pode ser acessado com uma das contas de motorista criadas por padrão, ex:\
User: joao\
Senha: motorista123\
\
Demais logins padrão podem ser encontrados no arquivo database_helper.dart, em lib/data/local.
### Fluxo do sistema:
Um usuário administrador deve cadastras transportadores, motoristas, e veículos, e com esses itens presentes no sistema, pode planejar uma viagem, com preço calculado levando em conta distância entre origem e destino, e peso da carga. O sistema confere se o peso da carga não ultrapassa o máximo suportado pelo veículo, a validade e disponibilidade de cada um dos itens de estoque em cada centro de distribuição, e disponibilidade dos veículos e motoristas. Após marcar a viagem, o administrador pode também emitir a nota fiscal.

Já o motorista faz login em sua conta e pode conferir se possui viagem agendada, e dar início à mesma se for o caso, como também conferir seu histórico de viagens anteriors.


## Notas
O sistema foi testado primariamente via VS Code, no sistema Linux, usando as distribuições Fedora e Ubuntu.
