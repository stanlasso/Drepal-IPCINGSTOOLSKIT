#####################################################################
# author : SCR 21/10/21                                             #
# ce script permet de faire de l'importation de données genomique

#####################################################################
import streamlit as st
import pandas as pd
import upload
import subprocess
import os
from collections import Counter




def sequence():
    user = str(os.getcwd())
    # st.markdown(
    #    """## **Bienvenu dans l'option d'importation et de téléchargement de sequence genomique.**""")
    # with st.expander("USER GUIDE"):
    #     st.write("""
    #  help
    #  """)
     
    type_genomique = st.radio(
        "For what purpose(s) is (are) your footage intended?",
        ("Clinical isolates", "Host reference"))

    if type_genomique == "Clinical isolates":
        st.markdown("""####  Local Importation""", unsafe_allow_html=True)
        oui = st.checkbox(
            "Do you have files larger than 4GB?")
        if not(oui):
            with st.expander("import"):
                data = st.file_uploader("accepted file format fastq*,gz*",
                                        type=["fastq","gz"], accept_multiple_files=True)

                if data != []:
                    name = []
                    for uploaded_file in data:                        
                        if uploaded_file.type == 'application/gzip':
                            name.append(uploaded_file.name[:-11])
                            upload.save_uploadedfile(uploaded_file)
                            bashCmdgz = ['bash APP/bashScripts/gunzip.sh']
                            processex= subprocess.Popen(bashCmdgz, stdout=subprocess.PIPE, text=True, shell=True)
                            outex, errex = processex.communicate()
                            if errex:
                                st.error('not gunzip file')
                        else:
                            name.append(uploaded_file.name[:-6])
                            upload.save_uploadedfile(uploaded_file)
                    nboccurence =Counter(name).most_common()
                    for nb in nboccurence:
                        if nb[1] != 2:
                            st.warning(f"check occurence number :{nb[0]}")
                            continue
                        else:                    
                            st.success("Import file successed...")
        else:
            chemin=st.text_input("Enter the directory path :")
            file=chemin
            if str(file) !="":
                bashCmd = ["ls {} | wc -l ".format(str(chemin))]
                process = subprocess.Popen(bashCmd, stdout=subprocess.PIPE, text=True, shell=True)
                out, err = process.communicate()
                st.write("Number of files counted {}".format(str(out)))
                st.info("make sure your directory contains only Fastq files ")
                if st.button("Deplacer"):
                    bashCmd2 = ["cp {} {}".format(str(chemin+"/*.fastq"),str(user+"/APP/data/Datafastq/"))]
                    process2 = subprocess.Popen(bashCmd2, stdout=subprocess.PIPE, text=True, shell=True)
                    out, err = process2.communicate()
            

        st.markdown("""####  Downloading from a database""")
        st.text("")
        with st.expander("Download"):
            tsv = st.file_uploader("import file", type={"tsv","txt","xlsx","csv"})
            if tsv is not None:
                tsv_df = pd.read_table(tsv)
                st.markdown("""##### Telecommuting in progress ...""")
                upload.save_uploadedfile(tsv)

    else:
        st.markdown("""####  Local Importation""")
        with st.expander("import"):
            data = st.file_uploader("accepted file format fasta*",
                                    type=["fasta"], accept_multiple_files=True)

            if data != []:
                name = []
                for uploaded_file in data:
                    name.append(uploaded_file.name[:-6])
                    upload.save_uploadedfileref(uploaded_file)
                st.write('LIST OF IMPORT FILES')
                st.write(list(set(name)))
                st.success("Reference import ...")   


