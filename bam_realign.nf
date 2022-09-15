#!/usr/bin/env nextflow

// Copyright (C) 2022 IRB Barcelona

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

params.help = null
params.input_bam = null
params.new_ref = null
params.output_folder = null
params.cpu = "8"
params.mem = "48"

log.info ""
log.info "-----------------------------------------------------------------------"
log.info "Nextflow pipeline to re-align BAM files"
log.info "-----------------------------------------------------------------------"
log.info "Copyright (C) IRB Barcelona"
log.info "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE"
log.info "This is free software, and you are welcome to redistribute it"
log.info "under certain conditions; see LICENSE for details."
log.info "--------------------------------------------------------"
if (params.help) {
    log.info "--------------------------------------------------------"
    log.info "                     USAGE                              "
    log.info "--------------------------------------------------------"
    log.info ""
    log.info "nextflow run bam_realign.nf [OPTIONS]"
    log.info ""
    log.info "Mandatory arguments:"
    log.info "--input_bam                 FOLDER                 Input folder containing one normal genome fasta for each sample"
    log.info "--new_ref                   FILE                   Reference genome fasta file for minimap2 alignment"
    log.info '--output_folder             FOLDER                 Output folder (default: SV-simulation_output)'
    log.info ""
    log.info "Optional arguments:"
    log.info "--cpu                       INTEGER                Number of cpu to use (default: 2)"
    log.info "--mem                       INTEGER                Memory in GB (default: 20)"
    log.info ""
    log.info "Flags:"
    log.info "--help                                             Display this message"
    log.info ""
    exit 1
}

assert (params.input_bam != null) : "please provide the --input_bam option"
assert (params.new_ref != null) : "please provide the --new_ref option"
assert (params.output_folder != null) : "please provide the --output_folder option"

input_files = Channel.fromPath( params.input_bam+'/*bam' )
new_ref = file(params.new_ref)

process realign {
  cpus params.cpu
  memory params.mem+'GB'
  tag {sample}

  publishDir params.output_folder, mode: 'copy', pattern: "*realigned_bam*"

  input:
  file input_bam from input_files
  file new_ref

  output:
  file '*realigned_bam*' into realign

  shell:
  sample = input_bam.baseName
  '''
  samtools sort -n -o tmp.qsort.bam !{input_bam}
  bedtools bamtofastq -i tmp.qsort.bam -fq !{sample}_1.fq -fq2 !{sample}_2.fq
  bwa mem !{new_ref} !{sample}_1.fq !{sample}_2.fq
  '''
}
