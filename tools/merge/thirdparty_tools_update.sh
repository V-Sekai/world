mkdir -p thirdparty
curl -L https://gitlab.com/wavexx/git-assembler/-/raw/master/git-assembler -o ./thirdparty/git-assembler
chmod +x ./thirdparty/git-assembler
# RERERE is not allowed because it causes merge state to be on developer computers and cicd won't be able to merge
git config rerere.enabled false