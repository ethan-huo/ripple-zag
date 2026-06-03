import * as fileUpload from '@zag-js/file-upload';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { X } from '../../lib/lucide-icons.tsrx';

export function FileUpload() {
  let service = useMachine(fileUpload.machine, {
    id: 'file-upload',
    accept: 'image/*',
  });
  let api = track(() => fileUpload.connect(service, normalizeProps));

  return <>
  <div {...api.value.getRootProps()}>
    <div {...api.value.getDropzoneProps()}>
      <input {...api.value.getHiddenInputProps()} />
      <span>{"Drag your files here"}</span>
      <button {...api.value.getTriggerProps()}>{"Open File Upload"}</button>
    </div>

    <div>
      for (const file of api.value.acceptedFiles) {
        <div {...api.value.getItemProps({ file })}>
          <span {...api.value.getItemNameProps({ file })}>
            {file.name}
          </span>
          <span {...api.value.getItemSizeTextProps({ file })}>
            {api.value.getFileSize(file)}
          </span>
          <button {...api.value.getItemDeleteTriggerProps({ file })}>
            <X />
          </button>
        </div>
      }
    </div>
  </div>
  </>
}