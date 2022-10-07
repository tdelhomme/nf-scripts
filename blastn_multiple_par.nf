
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
params.input_fastq = null
params.input_genome = null
params.output_folder = "blastn_nf_output"
params.cpu = "8"
params.mem = "20"

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
    log.info "--input_fastq               FILE                   Input fastq file"
    log.info "--input_genome              FILE                   Reference genome fasta file for minimap2 alignment"
    log.info ""
    log.info "Optional arguments:"
    log.info "--output_folder             FOLDER                 Output folder (default: blastn_nf_output)"
    log.info "--cpu                       INTEGER                Number of cpu to use (default: 8)"
    log.info "--mem                       INTEGER                Memory in GB (default: 20)"
    log.info ""
    log.info "Flags:"
    log.info "--help                                             Display this message"
    log.info ""
    exit 1
}

assert (params.input_fastq != null) : "please provide the --input_fastq option"
assert (params.input_genome != null) : "please provide the --new_genome option"

par_comb = Channel
    .from("-7","-5","-4","-3","-2","-1")    // penalty
    .combine([1,2,3,4,5])                   // reward
    .combine([0,1,2,3,4,5,6,8,10])          // gap open
    .combine([1,2,3,4,5,6])                 // gap extend
    .view()

