ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r�Hv��d3A�IJ��&��;ckl� 	�����*Z"%^$Y���&�$!�hR��[�����7�y�w���^ċdI�̘�U�8}�vn�8}�b��̀��l�@G����C������@,&ѿ�xX�K!"	�GbD��Ű �	��c��pO�/ǲ�	�#ۄ]͚������ȴ4ll�g�gg!��)���8 <�0��g�Ͱ�f ��h��jm� e�~�:R����C�`Ӷ\� ��-aKئ�=ce��j&6�Ȱ�H����A%S��:(f�m�� �+�^��j����d����l�B��˛�$���吱�L4�!SVۚ�/���:X)&�i��A���I/�F*!6��(�&]`��&4���sQ��|2�M�'�a �&�vh⺦��lx����fjʢ��RL�c���8dYe���"
6���!�P���?��m�q(�34Y<���uka�Za�.sD�aSE&a��k<F}Z��Ӯ7̎�
y����;:�#؎Qa��S�g��P\���'jX��V���Ӵ΁���E��b�e8�����!�W`��㗖�Ȑ?gԟ?usd��{Z_}t�e��ǖ�Rf�t��4Q�0�M)F>�wn�P�Dl��_��(8�=l��]QQ:�g=Ѕ�L�C[2i�>x���\PQ7@�?��н�A��x<:��������$Q�<�{�������o#�F���נռkl����_���G#R8,J�\�K���x�]�������SA��(*��j&՘��UR��~��S����6y�����Sɧ�C�lf��u�f�?�}���U���Z�Wk���a��w�҂<��q/m��?i�����S�[���t�����6�c'b��Q�t�h�d�
+����Y�9�ul��Z�Cň�i٠�tg��1�.�i�l�A��D�fc���'<��6���В'M�F7���g�6ƺ��9oS�C�nbs��)��p��k
2,ֶL���a�,�&��:���c{Yӱ�R��?��-�;tB-ڑ��4w�AvÊ������o���h����Ժ�o8z�=�A��C����h�d!���.J�O�`"8<O`��ƥ�>���>"�=IL=�!5�� j��&��������i�v�.��/L�N��� 
�Z����?�	�^�;;�vڠ��:��
L��]D
0�Ќ�襐���,w�orWw(�<}�2>nrZ����H<��v σ��(I���41��H{�6$�^o����� D6�z-�~2�\]#��'�㭇�^��6�f�6`A�N��Y����g��%� �@���(l�G�������w�-�F{<�a�@��c:hW����ߙ���9�YV����>n�U��aC�	�_=<}s�	�.}:ܱ"u8z�\��+9��*Ѿ��|��M2Q.wX����:�ґb�^SS� 3��x��h�<g�	�l���:yo�y���y����l��?���+�	��*m�)�񏲧�d��
���`�ի�T�>�;5��W`]#x�B��rdA�S����K���2ҽ��P���O,���>���a������X"���O˿�>�]�~Rzt�zg��;�!��>��Qw��:�Qo7g�9�I)�A�l��t���	ꄫ��+*�r����3�Mȫ&�?{�]��<{z5�<xF�Ĝ��%�r�r��O}8Δ+��⋋��m���	�Y�1,d�$N��in�����k`�U�!�B�i�t+����#�Y�S���JU.W?T���Qu~�'�f�]���"��Z�׆0Q{G��c�~��v���H��E�~޾Og6��g��D��{�oI�s9��۠H\q�]C&~�>����@�u�,��N x�J���߀y*�;.��lAP�I.�#6C�+d�`��N΋軋5����k�o5����l�����}��e��i�/���p���=�T���i� �� 蘨�]��'��z�}�u�3��_�{��ߋ����:�s�|���N\p���o������%(x����L�$[�������݅c���M��4��tLͰ���64T+��x u��G6}���N�'�D�\N����0�h����(���D�l������}��%=��O��e�6�AF���!ω�/2�N?��{�J��bA�>UB/Ǻ/�Ign�L�H�;�NS�
�i����'f�:���=3�Vq��&�F{
ytc&��XC,�H�*��	����w�T��	�)q��ӧY��=��k�� 7��w	
_f�����O$B����x����j�j�C��a�ե���ΈJ�o\���@��x������63 1(�e�
�����m*x�wo�v��Z���x�o*�w	
X&�Q)6%��hd-�+�_���G��2��F�5�zb�)>�5��Ǐ
�/�U���������ش�K��:�w%pW�����mvCd�3}z?��N`� �|ƞ2:�F0��k�HwA�3�*�tf( �@�[�v�I�~0��6���B��?�d������	���Mݥϖ23Eɕ{���F��l[��d�K�%��wL�蘨#�/�dB���8�32lL���9c���d�cLT˅19ԩD2O�v
���2���˕2�g���8�^�̬�KCMhS��#U��dލ-�j�P��������6n�/�����p��)1W=�em�^p�W�Ƨ��Qi�����k��������7�������Ô���'�	�$�[uETD)뵺�l%�z-��q�$I1)QKD$J�h"!��[�pm+������|�Mސ7���;���5�Gd�����+j�6}���Rذ�ikN{�7���Z�Q������_��$��_}�Ո�s�g����o~����#�����͉I6������o��q�2��c8^��������Wޅ��?�po����DX����'���n�&m,�����/ń�Z����=�xQ���TR��4�YH�Mҗ<������<yz=��d)�}�[Z��������Q� �	(��%���[	TW�ږ���Dx"��BA�H�ŭ8L��8�	(I�8iB�]�
"j�N� N�B2��A*S����\Ͱ�wF!�O��S)YI5�^>)7�e����}5���񛸆3-��K5N�{�,y.dnO���
r+'�G�d��:>.\d.�r�Q<&���V�Y���Z�O2�s��}�T��䙖̽3�v�9뗧ᭋ\U~�b�j&��]f��7�f�M�:�D�ka�b7-C�P̈́��w�~{&fo��U�W<χռpP͇Oh�9+�e�d�P�z��i��T�ez���.3��8:�T��W
g-xr�U���i5sRH�ܑ_�p��g���'�s��x^���I�aȽ�I�lÓ�L��(T�:�em%w�﷋�Z5yFf2Y�%�s�����\*�}�eve!/'s���E�$�Z�j��w��7����yԎ��<�������~��8����pO��B��i�B�,~�饷��x�*���ؙ������j5�_�%���j��I�z%�ƻ��\�s�[.$��VF>��Bʢ�R�R��ړ�ɶy�x2�L�3��~�����i	�ÃSHec-�:�K��)��Y��,4�B�(�/�$k�{g�2����)���e"z�5���t>�*��Q�8�M��F�Q���p�����,�t`&�+$�N��渰{����Z<*�;���bz���� 
�~��Fc_3Z�c��?��S�����(Ƅ�#��@�����71��-{�+�O��w�����s�}+Z�%�������(F��+�1?鰜?&��eNY�c�����,/��ɜЃԇ*������'��Jh�Z�1wv �*�Nt��g�H�,��$.WJ��f7e����N�u������c����j<���Q�T���YE��w�9��j�G;Ճ0
CE����~z�*�6J���z������>���r��a����?������f������2�x��_��\	�����~>5n���^�w������KJ�Ԑ30�33���f_.NN���F�#�9|�=�Z�8�7�q��hb,�㎸��ߺ��mȇ=q��zBb�c4�y��;;�|�g�{�~;�	���ؘ�ԵF�o�+aK�?v=�;*��?�����M�O�7����2-�@1�P��ey�~�w��ܳܺ��m0�K�b���P����a�  Ҩ����u��H[�ؠ�O��%``�]x��.�����������v ُ��Z  ��P3��X|+��)E��A
[�
B��v��jH�=�DU��l�L?PoXWF?F��-��� �w��1�ȶa�aO��2/#?������f��d� [Gk7Y�#?�,2`Mw�����Ǯ�X�F&�pV�ǎ��s�c2�
P 8��x�z�c,�)UD���+�.�6�  M�i�����65d�bFe}ڶ��.T��1���ۓ)��y}t4����&�~�����4,/�+]����3l�������o��P�V���ф��b�󘚊���	N��*��%��_{鮎6Ix{b�u~0�o.'�B"^n���@�'sۅ�CX7q�u���'M/I͡DD�k�%0�ա��Ez?�`�=�m�W��1)����}���91��P�W����;:�M��k�M�}0dK�"�"kgf�jМS~�p�e(��_�k�{�{ѓ
D����&�T	�4��a��EèY���2ƃ��K��q�������o*����Iaǰ��N�C�_$���n�8�Cf	�sVi�{���+b��]���}�#��}��>i��&�tۥOE��p�7�"X�D�}�Ȯ�ʐNM*�vl�NQ*��XD�����M05l7=z�Jw3Y��a�a��펎�����&��B2�
m����X������8�:�〻l�n�>W��o��_0��Y2���|��e���L��,�[���{sP��Pj[T���5���$�e<c�@=bÝZ�%��O��m �Xh+�~�da���������g�Zb��rwO�\�MO��~P0C�f�Q_��H�$�)���I���<Y\9��8q7v�$T,��Ҁz���vĤ-`3!z�X�@����G��}W��Vߺ�>����w�� �߽$��`(�%��?���o�s�/�=�+�o~���b�o������/~����%��8�9�|G�o����Go�b������	U���0��dE¤pH�P�Z�P8ҔCxL�H
k��n�R!�2Nd[��9d�B�������������?�������tn� ��Ɓ�Ð�b�����>��
E�����w�����{��� ���G����P���a�ˇ�z����o��[��v���+ ��2p�b6��u��򱡥c)��{e�a�S��9��{�|���=f	�U�m�U.�
�Ӳw��nT������b����0�yvIB�>zR�5$���~V�!BJ�Ǘt�F��EZ��BQ09{h<g��zu>nb��@�
ź���g�5�p�8Lw���EdgB�o&L�ᔛ3��[�̠�Wq��,O�D������<,�ͳ�z�ܝ��H�@�T�a���~�/O�f gλhչi��y}���K#����X�5Š�t�ZL��Hw�Hdg%�ܜ)�b��2�])��ɂn�<]H�m�}'9�(D�����za��dM�Y�3�M@ϖ�B�
a��:I���#:�I7�s�|�4Ҥ���Y���������ÛE�hUY��N|1�Z�g0u��2�E5ry�f���3�u��֗��i'�'kZ�LRҬZ*E:9�ҳq�ss�?9�Ǌ�!����%tu6��.���Jn���+��+��+��+��+��+��+��+��+��+�����1�w�7K)��~�T��d��α�v�YMċ1��ĩl��i��p��v�{Q;+
�U99_"@��E� ࡐ��Z� @��N�D͔� t7o`������Z���S�!VLF��М!2�<2�H�*�[��6K�X5E��L�PK��9��U�
'�R�Q459��Mpb46GR�,PW���?7Q?�ƈn��X��X��Ζ��k�TN�{KoEd�2C�¹y���ЩY8�Ñ)��Q
>����L�5�z�Sd�HGq���Z&B�X-��
�̝VT��(�&�<"cmVj����`��%\�]�B��_�����G����8z������c�y����p�]��wC�3佸}.6���0?���"�I�����ܾ?� u���ԩ���w pd�����׼\T,�G���G��}��o ��\��|����O��0�����_)�2KK���J��Ft�u��3�E��k��nm�|I|�:?��%W�ǉM�o�	[���I������,X�ӕ\�m�f��Bl�U0��#�LcS���J��~&JU�E��r�Ϭ��0&�cB�QJ�%�HE�T�J�㼒���Wg�rl�gs�o�S�� �7��n��ユ���IӘ7´mW��A"�Q�q�2£&R�-e�P�C�,�]��Y�i2�:~�Y:���4�
qH2�)�L����r�24�Q�r;y�G"���[h�`�Ҩ[��zI�"k���M�,��*�֔E?_K6q�[*8&*�H�_�YD#�hA��f������icL/�m�2C�֔��l���tm�VB'>��_f<��+�&�g(�i��˃�0�d�h&�w���rK��_��/���̦��X��@fٮ����p�������Ȳ�EVY�x��=3+=.�;r[~w��6~��;ݳ�D�Yզ���T8��B.ӡeO6t�������3y����i��`�aI�f��~U-��Ju��a�)f�a�nm��|�F�x��6�4U��g���P�
-Цm(s��h�<�����&?�;��\ G�B>�w������Ǒj�����	�B0�s�҉'��.Y|���i��+�FEI��}�,��t)2K#L�͛�!p�y�(Z�a�p4�J����s��.L�+źx?��!��(�^���&��+y"+E�X)!;�Ú�
x���])$lY%f�ݯ"�I�Q$�k?j�m�`��	�	r�#W� +;�Re"Y�1W��9�*Ŀ�Z����P�\i����:����'O�ꀋM�$�sq�nW��Q(��[�c\��X��EI���YJ+�G�n2�-�ә�D��	�(�U(��Qv(�H9S�C�L�|�4%/�C��I��T�<�)ļ�N��R���
Ct3j)���p�,4�S��+U�!ҵZl��g$����J���Q˨Ę�y�J��)0��(,���am!6�j��c�w3yvihe��j�[���g��x�o�y��n�~���d�v!��%�c�ݘ��W������/#?Ns��>���X	<���������1�3�d��%u���}�<x��9����A/Ϸ�w`�v�x7�&�����)�u|èH�*�>$����$��J����ȃ�������Yu��G���	��p�dHN���9���;�_+}���#�šey�躢��#�C����=z]���Y9B^��;���[|�x"c~=�/LW|�èЖ��p?|��Gz9�_��>z�	�:�G���Y��V���5����N� ��T�|9ص2����#�A�ɰ*I���4P�.v�����Q o��f_����'0���ϑ�I�3��U?��vW@��wN��:oXU��e��ѥ�e�p?]��xo}�Y׋llݮ��V �W��bNvt�dG�^6��S�{{��:����dC�N���Ѹ�G�ڀ"��=,iA�1
@>ڈA�)��Yt?Q`��� �3����PїA������a���&����� �1^0�s�$䍠�M598T,��]N}*�~yj�Wsj�2 ��,>_�� �jd�0�!�l�x�xK|t���]�C�8s"�������W��Zom���A��h��p�NFC�Wf�:竍g���`�`}?iE�<�Uae�Wa�ɪ�
E��c,]gh�cm�kd�v���N�k��Б��1�>k�c�,�ۀ��ɸ�Ћ�'�� �a~�[�X�N�őU��	WDV���_�����	?3 WL�Xٜ�M�����u�y�����h�lH؏���V��u���ůK~������&x�d2�u��c�������Б��� �N�
��`iA�덺\��Yp���7��O�x0�27�j��'p��yC��G I	|�<���E>�]]�R�88sx�n�%��}<�%��h+[�0(i�+YE��֕��r��m)y��S���p���t;��
�Rɽ}Q�.�z&��}�*i��s�����/���;u��[ Y춽-���/�x�݅�A���4 (O(t�Ǡ����푋�*T
6AYX��,�$H�뵃�`g�����z`u���A΀$ xU9�cM�H�`��cf�\L���+��5����
7i��悐1ktӚ穥�A��°&ٞ+��v�M�x��6��/��W&��YÒW]\u��J�9MX-;ǢA���.�/p�e�{c���_�v[���6,�i�q�U_�V�N��n��4���*Y�]l5�`WB�D�ԙ�S�''���ɨԃ�aM�!]�<���8� ��YW����lN�N :��O`����X�Mܶ6�4ND�b p�I�+I῜�FnG����- 	l�);JC:@��[�������c3�M���X��_�p�P>=�U ��~ԁ��x׎�e-���\�}�����o;�͕m\q�����?�P;���#���	�	� P[�U�#�-+a0��kD�}��=����Y�>�1����BwV��䎂%�X��,mU����G���|���v���?g���+:��7kG"Yj�H�IHR���E"CJ�lST��Rڸi�D4C��1Bn���%��QE"(�L�ۂ�=���� f>sb�XVi7���d�?��|b=y
�
c�\{;ě0�ξ��Y�xLjR��l6�p�Ȓ�J��I1I�(*S"X��*!�)�RȚ�hL	G\�$Ś���������'�'p6f��6P|����޹%�'���Nx�3���.*�2���,�#��+���l�+�\Ѣ�$��t�,�Kf�
�y&+�i��l|I�4��R��+�����_81�c����+��f/����k�*Ng�R�g���Ǯ�"]mua��ݳ.x�� ��ڑ���t��3�j�>i���N�����j�i];l�}�¶I{�L��Z�v�c;7L���l��9CV�Hv��%�)��V���=�+r�ȓ|6y��������g�9v���	�c�����˲���M���EQp��It2:��S�O��$h�̢�KO��y]n�`6���f��\��*�ʕ�x.���gYN�抧�5�g.��/��7��:���v&�]{�S�<:�1�j86i�-����?YZ���=����,sI�x�O��3&�/w�܈�d,~���m��(x�ę=xg�Y[�t���	��A�.bj��N�i��|��f��Ķ��7����B?&��
|k���2���Շ��Gm�;�$�0r�c��v�].nv��ݱ��VD�C��Y������
���^�l�x7�o׋6y7��&��!��>���Gw�q��Y�;qX�}���[2�6�""�a���^	��$���;���Gz��ohzK�M��C�C����B�S����Kz�?�c�򟌄�i_������}O�W6�K�_��'7�������t�@s�@s�@�B=��7K�(���#�����Kڗ���1���,��#Q�dG��f;D�Yj�"Q��PQ,��Bd$Ԍ��J�<LH�3�eQ�W;�
���o���_{I>�o3L�����:4��H+���9r\��hJh8�A��P��+�ye�In�O%�
�9�.rM}is����C
�1��-.��hY����Tč����[��餔��&�Jq��R�J�)�����1��������_~z�������˗�66��yH��>��6��8u8��Gz�?��8���>Ҿ������W>��A�߿��:�##����G�g����=_�t������l������W@�ë� t8%�:�����w�OR��:��}�WK�C?��P��K�����?��%������>�!T�!T�!T���we݉�]��_�޻V�<\�k}L*"(ܼ�I�	���Ī�hwR�
Е��RV*)E7��s�~��#�?�Z�?���'����?߅�2@����_-����� �/	5��� u��)�~����R�V�o\��p�m�S�z�9�ڍ���uB*[عp��YT���kBr���������~^C��������'���<o?��*!��c{���Odi�=$v��J�v��:�m��^3�j�[�i��X���-��l��V�k�����C�E��Ml���Ц/�H�ݷ�>ok�ȏ�}���j�dr�������v�8]*�'$}4�Ir�M7��<ݒ��)�w���^셩+G�9q�*qϦw�(%�,�i�����'+ߦh�86���ooX��z��?�;UICKF��Ǝ2���������5�O�`T�������C��2ԋ�!%�lԢ������ߥ � �	� ��������A����,�`��*@����_-�����W�����@����7A����C��������R�{���[�|��g4���*�vb����V�����u�KY�;��Y���G���;e���O��
ǳ��Ң��7�õb"�K�X�]ZqR._3j#'{��D9&��n��1=#�Sa票o�7CZ�59{*둿��!���S]/?�����sI�D#W�/m|���o߼�����y���N�#*���q�]��&��p3�/�)�tBЛmm�&�}�D����5IA��+&:ܨ���:N<;����Z�����+j�����Wj����9�'���
 ����u���{�)�����N��<��g�(�Ky$K��y!��1���>A.��8��(��>Ep���(����?�����������9��ɠ�j�4�%{��)]�\�8�EK�l#�-���,��#9�=y~Q'��YL������얓��8��d�����)�"9�$�7@�0	��QQ{�O�t �������?�C����
��������C-��*C�����q)�~1� ���P�U�_Y�tC���8n�����h>�h{����f�8�2�,9��?�G�}y$F�f̸�9��\�w�.Q4��,7c_O�.#te�~L${d6Ϋ\����s:���ؐyT%���PP��������V���}��;����a�����������?����@V�Z�?�����������"�{�� "�m�w��z��N&��iz��,*��/������3䢶�?s ���O���Y�><�"U��h�/��J��� �q�%��V�f��O�H6�]:�2h����͕^k�0Mi�oD�p�c�	/�һ�'��S�9�f���߬���H���8zy
ל���+^� 0얐k¥�	��.���80���|�E�PoG��X��uC�X#�²��O��L'm5���y�0��[a�L����ED�<��I>�Ɇ��#Uw���d�C����t�v�8��$��Az�ݎ�4[�{|,,B��I�:�ͯ��D���V�ytt�9>/������^4��������W>���0�Q_�q�������C��G���������R�2�j�����������|@�?��C�?��W�����E(E�a��є�yJ�(��������4Mr!��4�\O�p	X.$�si7���OC��G�(�J����u��aY(�MM�s��*��шO���s};"Z��Ġ�_s(y�4�g�,ȅ�l������ȇ�fM�4^�I���_��#�mr%8�:�m�\o�9�iY�>J�[0��^���������|>�_#�~���C���?M`����Z�?}����_I(���`C�{��_5�_�:��U�����~���	����'h����������/~�����Ho����>'&N��ʸ����J�%޽�˸>G~f����3���V6��y>6�ý;��ǝj�Aޜ�nX�$X{y2-m��>���xA�ii���VW�lz��Y���Uy��fS�0N�K�n2J��!����²��Ɠm��˕��ޯ׶I���;�=0�"p�n�[��z����W�~��-Z��.�!]�p?��l��!��jЈ(G[Ϛ�$�5���`$�
����G�Q����J'k�{�V"�����Ld2�:��"�1�@��|�ǲKC��E��������P�m�W��1�_+B����uC����4�� �a��a�����>O��WX ���_[�Ձ���_J���/��jQ�?��%H��� ��B�/��B�o�����(�2����Cv��U?O�c�q�?R��P���:�?����?�_����c�p[�������?��]*���������?�`��)��C8D� ���������G)��C8D�(��4�����R ��� �����B-�v����GI����͐
�������n���$Ԉ�a-�ԡ���@B�C)��������?迊��CT�������C��2ԋ�!�lԢ���@B�C)����������� ���@�eq��U�����j����?��^
j��0�_:�P���u�������u	�S�����?�_���[��l��B(�+ ��_[�Ձ��W�8��<ԉ�1�"=4dho��K���Oz�ϑ8^H�f�	�]�e\����\����e���}Q�'h�����0TF�
�?�<����Υ�����h�^�ÈPT�{=AM�&/=q��5�I��ǫ�qՒB���?̇�.��pw3�և�f/��+2�bD��U���!GK�l�3�Z��=���8�㍝$������M�>�{R�B�u(h�D��vwO���f����?�C����
��������C-��*C�����q)�~1� ���P�U�_Y�|B�N�}��[���"�Fo��� (��˿la���̧��}���p�7�J/�d�a��\	��A2f�9���U����ZʶiO�����4=���`�I�>���0G	U9H��b0�)����������-	5������w|m�����U����/����/�@�U��������#�����-����k�B7�X��sbd�#+DF��V���߳��J;Ip�����Dޓ�G�={�L-�ِ�KnK�fg�z��H$���8V:Y�M���{јF�9V�a�.�_{n;#2]?ǽ�Nɂ�-Wϴv�#��n���׌��K'^���%�py/�Hn	����5��e�>��fB�}	��b�~��b),��>a�3����~Y��5��s��-'i�3�y��G�l����q��O��33���-��e8	l���D��h��7�Ǔ(�L�Fx���l�R�����+����p����w�x�ep����ϸ������O\�׿ԡ�������]
>�����#^�E�����D1��ԁ�q������e�����L���,������G�8�_x���-Q����M?��t3����qB/���vׁ�=�W��$޼����fi���7��n����s?�v�d�!=��f�!�=?#����o�m]��ݬ��պ�:����ϱ%c����qZ��	B~�3�°G�*���^�P�j�����F��,f�l��G�0�����b��̩ޤ�}��m'�y�X��#l1�%�O,��ܢe���'�͝�ڹ��eͅh*_��%~p����o�.��&>�')2bA�7��DC0��"wCl�mr#���j,B��K;d�Z�z�2Gz����|ދMV�"�K��Q�h�;?�p�\#�
�B,1�	��t��<Mу��rM�O{�@�)����8��3�Ҫ/����������KB9���(ԣ1��������s/����PGqz6���f.�x�O�h�q��>�f�g������E���_)��������?(��[y(";�n:�[wq�'�P�,������˕?��#r�V`����������@���H���@������RP����������G���Ѡ�J�[�_����w�OٳǾ���@�u�N�`����U���筗�:9�������|��[~�C~���Z�;���&�7���n��>�� ��1�ku�-�݆����@8z@��j��1��Fo�i�kt���ܧyq�~�����!�����ɺՍb%펮��Q��f�!|?ד�u,��(��Y�!��w�ɖW��Y���d>���U���Ǔ�L�f���z��V8a��)Q"��F�^ڹ�����y�U�f�4Úsa��U�p���XYtɦ�h+��;+�|���~7�A���`���p��\�'��fY%f,�_;~>}��b�p�y����ˢ���/� `1
wq��<����'���������������_�C��6j-��r��i�R'r��P)��2o�h���/���˖�jA>*[��{/>�������(�e������
�����w���p�c-��_5�C�Wu(���c �T������A����������޷��i��(��������Yt����_��`k�r��>��U�۹��Z��B�o"��H�Lh���/�.-��*�<�<?&}{,-�ޭs�|�uu�\!OGW.���O���o�ܟ�Ķ=�;7'u���t󐇞:�U��`�~{�V  > E����B۝t�3�̤�L\�������k���ڵ�>^���Jxa/�<���i9�Bg\�D{[[w:�T��hV�n�l=����}s|��*&��h�6�2�rڶ�t��H�1k	\�m����J	/Sh
�y���y�G�)q�<��n�x�=���gw;�b�ꇽ��v~��6lIi6F�í2�%Ym^���'�u����vcR��ld���j0��U���UL,ZJ�Ѷ�f�~���#ؕS�벵��R��p�qT��J%)�H]�+����|ß&�um�o��Ʉ,�C�?�����_��BG�����#��e�'_���L��O����O������ު���!�\��m�y���GG����rF.����o����&@�7���ߠ����-����_���-������gH���!��_�������_��C��@�A������_��T�����v ������E����(��B�����3W��@�� '�u!���_����� �����]ra��W�!�#P�����o��˅�/�?@�GF�A�!#���/�?$��2�?@��� �`�쿬�?����o��˅���?2r��P���/�?$���� ������h�������L@i�����������\�?s���eB>���Q�����������K.�?���D���V�1������߶���/R�?�������)�$�?g5���<7׭2m2��ͭb�5M�dR�����d˘d��ɱ÷�uz��E������lx��wz�(q��Fu����u��
M�)�ǭ�o2��wY��^�պ(����t�6ǝ6&w�Ɋ~HS,��8�m��/k��Ȏ�d�)-zB:]=h�V�E�Gu:,�q;,����m����d�U��\OS���՛�nǮU#�rEy�'����$YG���Wd�W�����E�n𜑇���U��a�7���y���AJ�?�}��n��%��:~��'jv��w�^���b�Q�ˆ��m��m��E��Ξ����Fu�j�[��j���#��͆�6,E�D8��~],���ߪb۰�sUk��ɫ�v��]mN���&�P;z��%�����7�{#��/D.� ����_���_0���������.��������_����n�QP�C��zVa��U���?��W��p���)VĚ8�)__�_ف����6��h�@*���z�.K�l�?���E��5}4o����D�0.L�x\��!iͱS��ˉI�U'�N��z�����~Q�j�J)l�[m,���m
��:;���_e�*��і����D�Z�F�1M!��bwXO����h�IJ�}v~s��V�~������^�|Jb���*P���r��KQ]٨5�V���v9X��ͦ2⇃8?LKQUZ�X�8���N�Y2D{�����qqېI�]?hB����|/Ƀ�G�P�	o��?� �9%���[�����Y������Y���?�xY������������Y������&��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�?��x{��#�����K.�?���/������ ���m���X���X�	������_
�?2���4�C����D�}{:bG[U�7��q������0�Z�)�#fs?��
����s?���L�G����"�w��Ϲ�������uy�ݢ��]�D�����8�P�;fm���\����j�7��O�gCvfNcap���M#��8:�!,Y��dSSmG��Q����Ѽ��_�Jޯ�WOG���\�F��4��
�}8V�����tu���_����Ug"��`1�lF90'<���%ik��Nt��jX#9jSo�}2�V,�X���`�fa�w��ReCi��DpT���vra���?2��/G�����m��B�a�y��Ǘ0
�)�������`�?������_P������"���G�7	���m��B�Y�9��+{� �[������-��RI��_�T�c�Q_D��q��Hmك�d�S����>�ǲ�<<�����،��i
���=��)������0��ыFI�h���z~��T�i��,u��7CS��W�*G}���hA�F�P/rq{+��eY!F�o� `i�����$�����B�{�X�/t)E�W��|aʜ�b�-?
�¢��nkO�����lX޴��P�G&��^S:K�X�!m�WЭ	�m�������?L.�?���/P�+���G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�c�V���L�������?r��?�������O�H&O��Q�Q�Nf��j�j�4*���<�ބ&{�`��Vb�埈`g��kL^�J���������ʝJ]X��5rr�4׉Y<�ZV p�|��n4��?_K���������q�������\�?�� ��?-������&Ƀ����������z�X�􎬊Ĝ�*Ċ��K���[Q�Ew��/�N��>�\_:���`K��_a;�YRL=4�,�G�~u�N�����[�iW||Ռڲn0.O������&^����24��%��E��3��g����``��"���_���_���?`���y��X��"�e��S�ϖ>�����ct�\���t/B�����S�����X �������wں�E[M�$������q��tc����r�J̧2�"��rV�#��'�`�)��Byh�X��a���שҬ�ڶ��RW�/�<,��DM���';O|�V�OE�;�q:&�BwX��u� v-a��$:9�6�RIv��������my�(�+�*"c���=QJ��S�M��MԵ�_�S��i�򳽈}U8P��Hԫ+��u��ˆď䓻p��J��ڞ[���b�n�0Fb��*4��Â�S�}�1�Յި���|8ezTqZ&�r�w��#O�9��}tx]���'����B�i&��?�ݹm�x������:��_v��Gm�(�����	bO�>J5�cG�?��+�y����<�Y���t�Ϧ��|L������]$�=c��������{=���G�����CI�������5�L�X���R��7?�%�����?}J����p�}���?�㾊��i>�����������.0�ox��D����n���Ǎpm�N������{,4#���'縉�i$����I_�zR��v��I�d���r��x�0qcfr��${{��(����7�x�#����w��~�c�=�I��%���w�����w܏�ɫ���[~I��OO;v������<Q�T ���;�r��}u��������<��XK����~��`m�m3�Ϗy��ӕ�渆�޳�M��"�`纎k��DނO��?q'w&�� �Bo�q�4����ÿ�Z�~����f�?�i,<��/���צ�������{��$�|��9��f@�{�M�t����?n�q��W��œ,���67aF���x�s�pM�ӓU=���SJZ��E�qwɍ'�{Տ�j�����H�VM�;���Hva*�����t�w�j�ez�w�ח������=q�}                           p��^=_ � 