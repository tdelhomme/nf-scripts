#!/usr/bin/env nextflow

// Copyright (C) 2020 IRB Barcelona

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
params.beagle = null
params.maps_folder = null
params.ref_folder = null
params.vcf_to_impute = null
params.out_prefix = "imputation_"
params.out_folder = "imputation_output"
params.java_scratch = "./temp/"

log.info ""
log.info "-----------------------------------------------------------------------"
log.info "beagle_imputation.nf"
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
    log.info "nextflow run IARCbioinfo/fastqc-nf --input_folder path/to/fastq/ --output_folder /path/to/output [OPTIONS]"
    log.info ""
    log.info "Mandatory arguments:"
    log.info "--beagle               PATH                   Path to beagle tool"
    log.info "--maps_folder          FOLDER                 Folder containing the reference map files by chr"
    log.info "--ref_folder           FOLDER                 Folder containing the reference vcf files by chr"
    log.info "--vcf_to_impute        FILE                   Input VCF to make the imputation on"
    log.info ""
    log.info "Optional arguments:"
    log.info '--out_folder           FOLDER                 Output folder (default: imputation_output)'
    log.info '--java_scratch         FOLDER                 Folder where to put temp files (sufficiently big, default:./temp/)'
    log.info ""
    log.info "Flags:"
    log.info "--help                                        Display this message"
    log.info ""
    exit 1
}

chrs = Channel.of( 1..22 )
//chrs = [22, 19, 18, 17, 16, 15, 14, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1] 

bg = file(params.beagle)
input_vcf = file(params.vcf_to_impute)

process beagle {
  tag {chr}

  publishDir params.out_folder, mode: 'copy', pattern: "*${chr}.vcf.gz"

  input:
  val chr from chrs
  file bg
  file input_vcf

  output:
  file("*.vcf.gz") into imp_res

  shell:
  pref = input_vcf.baseName
  '''
  #mkdir -p !{params.java_scratch}
  java -jar -Xmx!{task.memory.toGiga()}g !{bg} map=!{params.maps_folder}/plink.chr!{chr}.GRCh37.map chrom=!{chr} gt=!{input_vcf} ref=!{params.ref_folder}/chr!{chr}.1kg.phase3.v5a.vcf.gz  out=!{pref}_imputed_!{chr}
  '''
}
