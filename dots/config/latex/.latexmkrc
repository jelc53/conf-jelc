# source: https://tex.stackexchange.com/questions/611943/graphviz-automatic-compilation
$out_dir = 'build';
$pdf_mode = 1;
$pdf_previewer = 'zathura';
set_tex_cmds('-synctex=1 -interaction=nonstopmode -shell-escape %O %S');

# Use internal latexmk variable to find the names of the pdf file(s)
# to be created by dot.
push @file_not_found, 'runsystem\(dot -Tpdf -o ([^ ]+) ';

add_cus_dep( 'dot', 'pdf', 0, 'dottopdf' );
sub dottopdf {
   system( "dot", "-Tpdf", "-o", "$_[0].pdf", "$_[0].dot" );
}
