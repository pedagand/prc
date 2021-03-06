OPAM_DEPENDS="ocamlfind menhir core batteries"

ppa=avsm/ppa
echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
opam update
opam upgrade
opam switch $OPAM_SWITCH
opam init
opam install ${OPAM_DEPENDS}
eval `opam config env`
ocamlc -version
make
make check