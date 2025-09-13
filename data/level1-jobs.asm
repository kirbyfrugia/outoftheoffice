
jobs_title_len:
  .byte str_job_example0_end-str_job_example0
  .byte str_job_example1_end-str_job_example1

jobs_title_lo:
  .byte <str_job_example0
  .byte <str_job_example1

jobs_title_hi:
  .byte >str_job_example0
  .byte >str_job_example1

jobs_icon:
  .byte 71
  .byte 70

// "KAREN PC FROZEN"
str_job_example0:
  .byte 11,1,18,5,14,0
  .byte 16,3,0
  .byte 6,18,15,26,5,14
str_job_example0_end:

// "PRINTER LOW ON INK"
str_job_example1:
  .byte 16,18,9,14,20,5,18,0
  .byte 12,15,23,0
  .byte 15,14,0
  .byte 9,14,11
str_job_example1_end: