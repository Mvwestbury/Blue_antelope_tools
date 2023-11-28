awk '{sum=0; for(i=1; i<=NF; i++) {if ($i>0) sum+=$i} for(i=1; i<=NF; i++) {if ($i>0) printf "%.2f ", $i/sum; else printf "0 "}; printf "\n"}' $1 | awk '{
  if ($1>0.94) print $0" AA";
  else if ($2>0.94) print $0" CC";
  else if ($3>0.94) print $0" GG";
  else if ($4>0.94) print $0" TT";
  else if ($1>0.04 && $2>0.04) print $0" AC HET";
  else if ($1>0.04 && $3>0.04) print $0" AG HET";
  else if ($1>0.04 && $4>0.04) print $0" AT HET";
  else if ($2>0.04 && $3>0.04) print $0" CG HET";
  else if ($2>0.04 && $4>0.04) print $0" CT HET";
  else if ($3>0.04 && $4>0.04) print $0" GT HET";
  else print $0" UNKNOWN"
}'
