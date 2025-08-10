import argparse
import glob
import os
from pathlib import Path
import shutil

# Initialize parser
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="Input folder")
parser.add_argument("-p", "--prefix", help="File prefix")
args = parser.parse_args()


def main():
    print("Starting python...")

    if not args.input:
        exit("Please specify an input folder")

    prefix = os.path.basename(os.path.normpath(args.input)) + '_'

    files = [ f for f in os.listdir(args.input) if f.startswith(prefix) and f.endswith('.png') ]
    files = sorted(files)
    last_file = Path(files[-1]).stem

    total = last_file[len(prefix):]
    print(f'Reviewing {int(total)} files:')

    missed_file = None
    steps = 1

    input_folder = f'{args.input}/interpolation/input'
    output_folder = f'{args.input}/interpolation/output'
    final_folder = f'{args.input}/interpolation/final'

    if not os.path.exists(f'{args.input}/interpolation'):
        os.mkdir(f'{args.input}/interpolation')

    if not os.path.exists(input_folder):
        os.mkdir(input_folder)

    if not os.path.exists(output_folder):
        os.mkdir(output_folder)

    if not os.path.exists(final_folder):
        os.mkdir(final_folder)

    for i in range(int(total)):
        file = f'{prefix}{i+1:05}.png'
        previous_file = f'{prefix}{i:05}.png'
        
        input_path = f'{args.input}/{file}'
        previous_input_path = f'{args.input}/{previous_file}'
        
        if not(os.path.exists(input_path)):
            if missed_file == None:
                missed_file = previous_input_path
                steps = steps + 1
            else:
                steps = steps + 1
        else:
            if(missed_file != None):
                print(f'{steps} duplicate {missed_file} to {input_path}')
                
                missing_basename = os.path.basename(missed_file)
                missing_fname = os.path.splitext(missing_basename)[0]
                missing_fname = missing_fname[-5:]

                input_basename = os.path.basename(input_path)
                input_fname = os.path.splitext(input_basename)[0]
                input_fname = input_fname[-5:]

                if not os.path.exists(f'{input_folder}/{missing_fname}'):
                    os.mkdir(f'{input_folder}/{missing_fname}')

                if not os.path.exists(f'{output_folder}/{missing_fname}'):
                    os.mkdir(f'{output_folder}/{missing_fname}')

                shutil.copyfile(missed_file, f'{input_folder}/{missing_fname}/{missing_fname}.png')
                shutil.copyfile(input_path, f'{input_folder}/{missing_fname}/{input_fname}.png')

                print(f'./rife-ncnn-vulkan/rife-ncnn-vulkan -m rife-v4.6 -i {input_folder}/{missing_fname} -n {steps} -o {output_folder}/{missing_fname}/ -f %05d.png')
                os.system(f'./rife-ncnn-vulkan/rife-ncnn-vulkan -m rife-v4.6 -i {input_folder}/{missing_fname} -n {steps * 2} -o {output_folder}/{missing_fname}/ -f %05d.png')

                i = 1
                for filename in sorted(os.listdir(f'{output_folder}/{missing_fname}')):
                    if(i > 1 and i <= steps):
                      filename = f'{output_folder}/{missing_fname}/{filename}'
                      final_basename = os.path.basename(filename)
                      final_fname = os.path.splitext(final_basename)[0]
                      final_fname = final_fname[-5:]
                      new_id = int(final_fname) + int(missing_fname) - 1
                      shutil.copyfile(filename, f'{final_folder}/{prefix}{new_id:05}.png')
                      print(filename, f'{final_folder}/{missing_fname}/{prefix}{new_id:05}.png')
                    i = i + 1

                steps = 1
                missed_file = None

    print(f'Reviewed {int(total)} files')

if __name__ == "__main__":
    main()
