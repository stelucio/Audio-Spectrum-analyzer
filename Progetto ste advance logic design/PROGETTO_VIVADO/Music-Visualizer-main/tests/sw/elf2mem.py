import sys
import subprocess
import os

def elf_to_hex(elf_file, output_file, objcopy_path):
    # Su Windows aggiungiamo .exe se manca
    if os.name == 'nt' and not objcopy_path.lower().endswith('.exe'):
        objcopy_path += '.exe'

    print(f"Eseguo estrazione con: {objcopy_path}")
    
    try:
        # Estraiamo solo la sezione .text
        subprocess.run([objcopy_path, "-O", "binary", "--only-section=.text", elf_file, "text.bin"], check=True)
    except Exception as e:
        print(f"Errore critico durante l'esecuzione di objcopy: {e}")
        return

    if not os.path.exists("text.bin"):
        print("Errore: Il file binario temporaneo non è stato creato.")
        return

    with open("text.bin", "rb") as f:
        data = f.read()
    
    with open(output_file, "w") as f:
        for i in range(0, len(data), 4):
            word = data[i:i+4]
            if len(word) < 4:
                word = word.ljust(4, b'\x00')
            val = int.from_bytes(word, 'little')
            f.write(f"{val:08x}\n")
    
    if os.path.exists("text.bin"):
        os.remove("text.bin")
    print(f"Successo: {output_file} generato correttamente.")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Uso: python elf2mem.py input.elf output.mem path_to_objcopy")
    else:
        elf_to_hex(sys.argv[1], sys.argv[2], sys.argv[3])
